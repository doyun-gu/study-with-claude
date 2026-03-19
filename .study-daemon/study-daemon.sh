#!/bin/bash
# study-daemon.sh — Bridge between Claude Desktop and Claude Code
#
# Watches for task files created by Claude Desktop and runs them via claude CLI.
# If a remote worker is configured, dispatches tasks there (survives laptop sleep).
# Falls back to running locally if the worker is offline.
#
# Task flow:
#   Claude Desktop writes → .study/tasks/pending/
#   Daemon dispatches → remote worker (if available) or runs locally
#   Results appear in → .study/tasks/done/ and .study/*.md

set -u

# Load config
DAEMON_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$HOME/.study-daemon/config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Defaults (overridden by config)
STUDY_DIR="${STUDY_DIR:-$HOME/study}"
TASKS_DIR="$STUDY_DIR/.study/tasks"
DAEMON_LOG="${DAEMON_LOG:-$STUDY_DIR/.study-daemon/daemon.log}"
CLAUDE_BIN="${CLAUDE_BIN:-$(which claude 2>/dev/null || echo "$HOME/.local/bin/claude")}"
POLL_INTERVAL="${POLL_INTERVAL:-5}"
COLLECT_INTERVAL="${COLLECT_INTERVAL:-30}"
COLLECT_COUNTER=0

# Remote worker config (optional — leave empty for local-only mode)
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_STUDY_DIR="${REMOTE_STUDY_DIR:-$HOME/study}"
REMOTE_CLAUDE="${REMOTE_CLAUDE:-$HOME/.local/bin/claude}"
REMOTE_DOCS="${REMOTE_DOCS:-$HOME/Documents}"
FLEET_AVAILABLE=false

# Allowed tools for claude -p (matches .claude/settings.local.json)
ALLOWED_TOOLS="Read,Write,Glob,Grep,Bash(sleep *),Bash(say *),Bash(printf *),Bash(bash .study-tools/render.sh *),Bash(open .study/rendered/*),Bash(mkdir -p .study/*)"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$DAEMON_LOG"
}

check_fleet() {
    if [ -z "$REMOTE_HOST" ]; then
        FLEET_AVAILABLE=false
        return
    fi
    if ssh -o ConnectTimeout=2 -o BatchMode=yes "$REMOTE_HOST" "echo ok" &>/dev/null; then
        FLEET_AVAILABLE=true
    else
        FLEET_AVAILABLE=false
    fi
}

sync_to_remote() {
    # Sync study state, tools, commands, and config to the remote worker
    rsync -az "$STUDY_DIR/.study/" "$REMOTE_HOST:$REMOTE_STUDY_DIR/.study/" --exclude="tasks/" 2>/dev/null || true
    rsync -az "$STUDY_DIR/.study-tools/" "$REMOTE_HOST:$REMOTE_STUDY_DIR/.study-tools/" 2>/dev/null || true
    rsync -az "$STUDY_DIR/.claude/" "$REMOTE_HOST:$REMOTE_STUDY_DIR/.claude/" 2>/dev/null || true
    rsync -az "$STUDY_DIR/CLAUDE.md" "$REMOTE_HOST:$REMOTE_STUDY_DIR/CLAUDE.md" 2>/dev/null || true
    rsync -az "$STUDY_DIR/.context/" "$REMOTE_HOST:$REMOTE_STUDY_DIR/.context/" 2>/dev/null || true
}

dispatch_remote() {
    local task_file="$1"
    local filename=$(basename "$task_file")
    local task_id="${filename%.task.md}"
    local prompt=$(grep '^prompt:' "$task_file" | sed 's/^prompt: //')

    log "[fleet] Dispatching $task_id to $REMOTE_HOST"

    # Move to running locally (tracks that this task is in progress)
    mv "$task_file" "$TASKS_DIR/running/$filename"
    local running_file="$TASKS_DIR/running/$filename"
    echo "---" >> "$running_file"
    echo "started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$running_file"
    echo "status: running-remote" >> "$running_file"
    echo "worker: $REMOTE_HOST" >> "$running_file"

    # Sync latest state
    sync_to_remote

    # Write a runner script on the remote, then nohup it (survives SSH disconnection)
    local remote_script="$REMOTE_STUDY_DIR/.study-daemon/run-${task_id}.sh"
    local escaped_prompt=$(echo "$prompt" | sed "s/'/'\\\\''/g")

    ssh "$REMOTE_HOST" "mkdir -p $REMOTE_STUDY_DIR/.study-daemon $REMOTE_STUDY_DIR/.study/tasks/running" 2>/dev/null

    ssh "$REMOTE_HOST" "cat > $remote_script" <<SCRIPT_EOF
#!/bin/bash
export PATH="\$HOME/.local/bin:\$PATH"
cd $REMOTE_STUDY_DIR
OUTFILE="$REMOTE_STUDY_DIR/.study/tasks/running/${task_id}.output.log"
STATUSFILE="$REMOTE_STUDY_DIR/.study/tasks/running/${task_id}.status"
echo "running" > "\$STATUSFILE"
if $REMOTE_CLAUDE -p \\
    --add-dir $REMOTE_DOCS \\
    --allowedTools "$ALLOWED_TOOLS" \\
    --output-format text \\
    '$escaped_prompt' \\
    > "\$OUTFILE" 2>&1; then
    echo "completed" > "\$STATUSFILE"
else
    echo "failed" > "\$STATUSFILE"
fi
SCRIPT_EOF

    ssh "$REMOTE_HOST" "chmod +x $remote_script && nohup bash $remote_script &>/dev/null &" 2>/dev/null || {
        log "[fleet] ERROR: Failed to dispatch $task_id — will retry locally"
        mv "$running_file" "$TASKS_DIR/pending/$filename"
        return
    }

    log "[fleet] Task $task_id dispatched to $REMOTE_HOST (nohup)"
}

collect_remote() {
    [ -z "$REMOTE_HOST" ] && return
    $FLEET_AVAILABLE || return

    local remote_statuses=$(ssh -o ConnectTimeout=2 "$REMOTE_HOST" \
        "ls $REMOTE_STUDY_DIR/.study/tasks/running/*.status 2>/dev/null" 2>/dev/null || true)
    [ -z "$remote_statuses" ] && return

    for status_file in $remote_statuses; do
        local task_id=$(basename "$status_file" .status)
        local status=$(ssh "$REMOTE_HOST" "cat $status_file" 2>/dev/null)

        if [ "$status" = "completed" ] || [ "$status" = "failed" ]; then
            log "[fleet-collect] Task $task_id finished on $REMOTE_HOST ($status)"

            # Sync state files back
            rsync -az "$REMOTE_HOST:$REMOTE_STUDY_DIR/.study/" "$STUDY_DIR/.study/" \
                --exclude="tasks/" 2>/dev/null

            # Get output log
            rsync -az \
                "$REMOTE_HOST:$REMOTE_STUDY_DIR/.study/tasks/running/${task_id}.output.log" \
                "$TASKS_DIR/done/" 2>/dev/null

            # Update local task file
            if [ -f "$TASKS_DIR/running/${task_id}.task.md" ]; then
                echo "status: $status" >> "$TASKS_DIR/running/${task_id}.task.md"
                echo "finished: $(date '+%Y-%m-%d %H:%M:%S')" >> "$TASKS_DIR/running/${task_id}.task.md"
                echo "worker: $REMOTE_HOST" >> "$TASKS_DIR/running/${task_id}.task.md"
                mv "$TASKS_DIR/running/${task_id}.task.md" "$TASKS_DIR/done/"
            fi

            # Clean up remote
            ssh "$REMOTE_HOST" "rm -f $REMOTE_STUDY_DIR/.study/tasks/running/${task_id}.* $REMOTE_STUDY_DIR/.study-daemon/run-${task_id}.sh" 2>/dev/null

            log "[fleet-collect] Task $task_id synced back"
        fi
    done
}

process_local() {
    local task_file="$1"
    local filename=$(basename "$task_file")
    local task_id="${filename%.task.md}"

    log "Processing locally: $task_id"

    mv "$task_file" "$TASKS_DIR/running/$filename"
    local running_file="$TASKS_DIR/running/$filename"

    local prompt=$(grep '^prompt:' "$running_file" | sed 's/^prompt: //')
    local command=$(grep '^command:' "$running_file" | sed 's/^command: //')
    local full_prompt="${prompt:-Run /$command for all available modules}"

    echo "---" >> "$running_file"
    echo "started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$running_file"
    echo "status: running-local" >> "$running_file"

    local output_file="$TASKS_DIR/running/${task_id}.output.log"

    if cd "$STUDY_DIR" && "$CLAUDE_BIN" -p \
        --add-dir "$HOME/Documents" \
        --allowedTools "$ALLOWED_TOOLS" \
        --output-format text \
        "$full_prompt" \
        > "$output_file" 2>&1; then
        echo "status: completed" >> "$running_file"
        log "Task $task_id completed"
    else
        echo "status: failed" >> "$running_file"
        log "Task $task_id failed"
    fi

    echo "finished: $(date '+%Y-%m-%d %H:%M:%S')" >> "$running_file"
    echo "---" >> "$running_file"
    echo "## Output" >> "$running_file"
    head -50 "$output_file" >> "$running_file" 2>/dev/null

    mv "$running_file" "$TASKS_DIR/done/$filename"
    mv "$output_file" "$TASKS_DIR/done/" 2>/dev/null || true
    log "Task $task_id moved to done"
}

# === MAIN ===
mkdir -p "$TASKS_DIR/pending" "$TASKS_DIR/running" "$TASKS_DIR/done"

log "Study daemon started (PID $$)"
log "Watching: $TASKS_DIR/pending/"
log "Study dir: $STUDY_DIR"

check_fleet
if $FLEET_AVAILABLE; then
    log "Remote worker ($REMOTE_HOST) AVAILABLE — heavy tasks will be dispatched remotely"
else
    if [ -n "$REMOTE_HOST" ]; then
        log "Remote worker ($REMOTE_HOST) not reachable — running locally"
    else
        log "No remote worker configured — running locally"
    fi
fi

while true; do
    for task_file in "$TASKS_DIR/pending/"*.task.md; do
        [ -f "$task_file" ] || continue
        check_fleet
        if $FLEET_AVAILABLE; then
            dispatch_remote "$task_file"
        else
            process_local "$task_file"
        fi
    done

    COLLECT_COUNTER=$((COLLECT_COUNTER + POLL_INTERVAL))
    if [ $COLLECT_COUNTER -ge $COLLECT_INTERVAL ]; then
        COLLECT_COUNTER=0
        check_fleet
        collect_remote
    fi

    sleep "$POLL_INTERVAL"
done
