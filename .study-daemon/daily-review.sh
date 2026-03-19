#!/bin/bash
# daily-review.sh — Scheduled daily study review
# Runs via launchd/cron, generates review + updates state files

set -u

CONFIG_FILE="$HOME/.study-daemon/config"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

STUDY_DIR="${STUDY_DIR:-$HOME/study}"
CLAUDE_BIN="${CLAUDE_BIN:-$(which claude 2>/dev/null || echo "$HOME/.local/bin/claude")}"
LOG_FILE="$STUDY_DIR/.study-daemon/daily.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Daily review triggered" >> "$LOG_FILE"

cd "$STUDY_DIR"

"$CLAUDE_BIN" -p \
    --add-dir "$HOME/Documents" \
    --allowedTools "Read,Write,Glob,Grep,Bash(sleep *),Bash(say *),Bash(printf *),Bash(bash .study-tools/render.sh *),Bash(open .study/rendered/*),Bash(mkdir -p .study/*)" \
    --output-format text \
    "Run /review — check what flashcards and drill items are due today. Update the state files. Write a brief daily summary to .study/daily-summary.md with: (1) items due for review today, (2) weak areas to focus on, (3) exam countdown. Keep it under 30 lines." \
    > "$STUDY_DIR/.study-daemon/daily-review.output.log" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Daily review completed" >> "$LOG_FILE"
