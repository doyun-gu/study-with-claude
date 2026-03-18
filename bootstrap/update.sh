#!/bin/bash
set -e

# study-with-claude updater
# Pulls latest from source repo, then re-runs bootstrap to update current directory

# --- Resolve source repo path from symlink ---

SYMLINK="$HOME/.claude/commands/where-is-god.md"

if [ ! -L "$SYMLINK" ]; then
    echo "Error: where-is-god.md is not installed as a symlink."
    echo "Run: cd ~/study-with-claude && bash install.sh"
    exit 1
fi

RESOLVED="$(cd "$(dirname "$SYMLINK")" && cd "$(dirname "$(readlink "$SYMLINK")")" && pwd)/$(basename "$(readlink "$SYMLINK")")"
SOURCE_ROOT="$(dirname "$(dirname "$RESOLVED")")"
BOOTSTRAP_DIR="$SOURCE_ROOT/bootstrap"

if [ ! -f "$SOURCE_ROOT/CLAUDE.md" ]; then
    echo "Error: Could not locate source repo at: $SOURCE_ROOT"
    exit 1
fi

# --- Pull latest ---

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  study-with-claude updater"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Source: $SOURCE_ROOT"
echo ""

echo "Pulling latest changes..."
PREV_COMMIT="$(git -C "$SOURCE_ROOT" rev-parse --short HEAD)"
git -C "$SOURCE_ROOT" pull --ff-only 2>&1 | sed 's/^/  /'
NEW_COMMIT="$(git -C "$SOURCE_ROOT" rev-parse --short HEAD)"
echo ""

if [ "$PREV_COMMIT" = "$NEW_COMMIT" ]; then
    echo "  Already up to date ($NEW_COMMIT)."
else
    echo "  Updated: $PREV_COMMIT → $NEW_COMMIT"
    echo ""
    echo "  Changes:"
    git -C "$SOURCE_ROOT" log --oneline "$PREV_COMMIT".."$NEW_COMMIT" | sed 's/^/    /'
fi
echo ""

# --- Re-run bootstrap ---

echo "Applying updates to current directory..."
echo ""
bash "$BOOTSTRAP_DIR/setup.sh"
