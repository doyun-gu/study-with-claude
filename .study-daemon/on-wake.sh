#!/bin/bash
# on-wake.sh — Run when laptop wakes from sleep
#
# 1. Collect completed remote tasks and sync results
# 2. Re-queue locally-interrupted tasks
# 3. Sync state from remote worker (e.g. overnight daily review)

set -u

CONFIG_FILE="$HOME/.study-daemon/config"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

STUDY_DIR="${STUDY_DIR:-$HOME/study}"
TASKS_DIR="$STUDY_DIR/.study/tasks"
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_STUDY_DIR="${REMOTE_STUDY_DIR:-$HOME/study}"
LOG_FILE="$STUDY_DIR/.study-daemon/daemon.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [wake] $*" >> "$LOG_FILE"
}

log "Laptop woke up — running recovery"

# Step 1: Collect completed remote tasks
if [ -n "$REMOTE_HOST" ] && ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_HOST" "echo ok" &>/dev/null; then
    log "Remote worker reachable — checking for completed tasks"

    for status_file in $(ssh "$REMOTE_HOST" "ls $REMOTE_STUDY_DIR/.study/tasks/running/*.status 2>/dev/null" 2>/dev/null || true); do
        task_id=$(basename "$status_file" .status)
        status=$(ssh "$REMOTE_HOST" "cat $status_file" 2>/dev/null)

        if [ "$status" = "completed" ] || [ "$status" = "failed" ]; then
            log "Collecting remote task: $task_id ($status)"

            rsync -az "$REMOTE_HOST:$REMOTE_STUDY_DIR/.study/" "$STUDY_DIR/.study/" --exclude="tasks/" 2>/dev/null
            rsync -az "$REMOTE_HOST:$REMOTE_STUDY_DIR/.study/tasks/running/${task_id}.output.log" "$TASKS_DIR/done/" 2>/dev/null

            if [ -f "$TASKS_DIR/running/${task_id}.task.md" ]; then
                echo "status: $status" >> "$TASKS_DIR/running/${task_id}.task.md"
                echo "finished: $(date '+%Y-%m-%d %H:%M:%S') (collected on wake)" >> "$TASKS_DIR/running/${task_id}.task.md"
                mv "$TASKS_DIR/running/${task_id}.task.md" "$TASKS_DIR/done/"
            fi

            ssh "$REMOTE_HOST" "rm -f $REMOTE_STUDY_DIR/.study/tasks/running/${task_id}.*" 2>/dev/null
        fi
    done

    # Sync any state updates from overnight
    rsync -az "$REMOTE_HOST:$REMOTE_STUDY_DIR/.study/" "$STUDY_DIR/.study/" --exclude="tasks/" 2>/dev/null
    log "State synced from remote worker"
else
    [ -n "$REMOTE_HOST" ] && log "Remote worker not reachable"
fi

# Step 2: Re-queue locally-interrupted tasks
for task_file in "$TASKS_DIR/running/"*.task.md; do
    [ -f "$task_file" ] || continue

    if grep -q "status: running-local" "$task_file"; then
        task_id=$(basename "$task_file" .task.md)
        log "Recovering interrupted local task: $task_id"

        grep -v "^status: running" "$task_file" | grep -v "^started:" | grep -v "^---$" \
            > "$TASKS_DIR/pending/$(basename "$task_file")" 2>/dev/null || true
        rm -f "$task_file" "$TASKS_DIR/running/${task_id}.output.log"
    fi
done

log "Wake recovery complete"
