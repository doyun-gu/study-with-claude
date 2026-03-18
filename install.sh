#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  study-with-claude installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Error: $CLAUDE_DIR does not exist. Is Claude Code installed?"
    exit 1
fi

# Create commands directory if needed
mkdir -p "$COMMANDS_DIR"

# --- Helper: symlink with backup ---

symlink_file() {
    local SOURCE="$1"
    local TARGET="$2"
    local LABEL="$3"

    if [ -f "$TARGET" ]; then
        if [ -L "$TARGET" ]; then
            LINK_TARGET="$(readlink "$TARGET")"
            if [ "$LINK_TARGET" = "$SOURCE" ]; then
                echo "  [ok] $LABEL already symlinked"
                return
            else
                mv "$TARGET" "$TARGET.backup"
                echo "  [backup] $LABEL — old symlink backed up"
            fi
        else
            mv "$TARGET" "$TARGET.backup"
            echo "  [backup] $LABEL — existing file backed up"
        fi
    fi

    ln -s "$SOURCE" "$TARGET"
    echo "  [ok] $LABEL symlinked"
}

# --- Symlink lets-go command ---

echo "Bootstrap command:"
symlink_file "$SCRIPT_DIR/bootstrap/lets-go.md" "$COMMANDS_DIR/lets-go.md" "commands/lets-go.md"
echo ""

# --- Summary ---

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The /lets-go command is now available globally."
echo ""
echo "Usage:"
echo "  cd ~/your-study-folder"
echo "  claude"
echo "  /lets-go"
echo ""
echo "Restart Claude Code for changes to take effect."
echo ""
