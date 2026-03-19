#!/bin/bash
# ctl.sh — Control the study daemon
# Usage: ./ctl.sh [start|stop|status|restart|logs|sync]

CONFIG_FILE="$HOME/.study-daemon/config"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

STUDY_DIR="${STUDY_DIR:-$HOME/study}"
REMOTE_HOST="${REMOTE_HOST:-}"

DAEMON_LABEL="com.study-with-claude.daemon"
DAILY_LABEL="com.study-with-claude.daily"
WAKE_LABEL="com.study-with-claude.on-wake"

plist_dir="$HOME/Library/LaunchAgents"

case "${1:-status}" in
    start)
        echo "Starting study daemon..."
        [ -f "$plist_dir/$DAEMON_LABEL.plist" ] && launchctl load "$plist_dir/$DAEMON_LABEL.plist" 2>/dev/null && echo "  Task daemon started" || echo "  Task daemon: not installed (run install.sh)"
        [ -f "$plist_dir/$DAILY_LABEL.plist" ] && launchctl load "$plist_dir/$DAILY_LABEL.plist" 2>/dev/null && echo "  Daily review loaded" || true
        [ -f "$plist_dir/$WAKE_LABEL.plist" ] && launchctl load "$plist_dir/$WAKE_LABEL.plist" 2>/dev/null && echo "  Wake recovery armed" || true
        ;;
    stop)
        echo "Stopping study daemon..."
        launchctl unload "$plist_dir/$DAEMON_LABEL.plist" 2>/dev/null && echo "  Task daemon stopped" || echo "  (not running)"
        launchctl unload "$plist_dir/$DAILY_LABEL.plist" 2>/dev/null && echo "  Daily review stopped" || true
        launchctl unload "$plist_dir/$WAKE_LABEL.plist" 2>/dev/null && echo "  Wake recovery stopped" || true
        ;;
    restart)
        "$0" stop
        sleep 1
        "$0" start
        ;;
    status)
        echo "Study Daemon Status"
        echo "==================="
        launchctl list 2>/dev/null | grep -q "$DAEMON_LABEL" && echo "Task daemon:   RUNNING" || echo "Task daemon:   STOPPED"
        launchctl list 2>/dev/null | grep -q "$DAILY_LABEL" && echo "Daily review:  LOADED" || echo "Daily review:  NOT LOADED"
        launchctl list 2>/dev/null | grep -q "$WAKE_LABEL" && echo "Wake recovery: ARMED" || echo "Wake recovery: NOT LOADED"
        echo ""

        if [ -n "$REMOTE_HOST" ]; then
            echo "Remote Worker"
            echo "-------------"
            if ssh -o ConnectTimeout=2 -o BatchMode=yes "$REMOTE_HOST" "echo ok" &>/dev/null; then
                echo "Status: ONLINE ($REMOTE_HOST)"
            else
                echo "Status: OFFLINE ($REMOTE_HOST) — tasks will run locally"
            fi
            echo ""
        fi

        echo "Tasks"
        echo "-----"
        echo "Pending: $(ls "$STUDY_DIR/.study/tasks/pending/"*.task.md 2>/dev/null | wc -l | tr -d ' ')"
        echo "Running: $(ls "$STUDY_DIR/.study/tasks/running/"*.task.md 2>/dev/null | wc -l | tr -d ' ')"
        echo "Done:    $(ls "$STUDY_DIR/.study/tasks/done/"*.task.md 2>/dev/null | wc -l | tr -d ' ')"
        ;;
    logs)
        echo "=== Daemon Log (last 20) ==="
        tail -20 "$STUDY_DIR/.study-daemon/daemon.log" 2>/dev/null || echo "(no logs)"
        echo ""
        echo "=== Daily Review (last 10) ==="
        tail -10 "$STUDY_DIR/.study-daemon/daily.log" 2>/dev/null || echo "(no logs)"
        ;;
    sync)
        if [ -z "$REMOTE_HOST" ]; then
            echo "No remote worker configured."
            exit 1
        fi
        echo "Syncing state from $REMOTE_HOST..."
        if ssh -o ConnectTimeout=3 "$REMOTE_HOST" "echo ok" &>/dev/null; then
            rsync -az "$REMOTE_HOST:${REMOTE_STUDY_DIR:-$HOME/study}/.study/" "$STUDY_DIR/.study/" --exclude="tasks/"
            echo "State synced."
        else
            echo "Remote worker not reachable."
        fi
        ;;
    *)
        echo "Usage: $0 [start|stop|status|restart|logs|sync]"
        ;;
esac
