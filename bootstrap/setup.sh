#!/bin/bash
set -e

# study-with-claude bootstrap script
# Called by /where-is-god prompt — does all file copying natively (zero LLM tokens)

# --- Resolve source repo path from symlink ---

SYMLINK="$HOME/.claude/commands/where-is-god.md"

if [ ! -L "$SYMLINK" ]; then
    echo "Error: where-is-god.md is not installed as a symlink."
    echo "Run: cd ~/study-with-claude && bash install.sh"
    exit 1
fi

# macOS readlink doesn't support -f, so resolve manually
RESOLVED="$(cd "$(dirname "$SYMLINK")" && cd "$(dirname "$(readlink "$SYMLINK")")" && pwd)/$(basename "$(readlink "$SYMLINK")")"
SOURCE_ROOT="$(dirname "$(dirname "$RESOLVED")")"

if [ ! -f "$SOURCE_ROOT/CLAUDE.md" ]; then
    echo "Error: Could not locate source repo. Expected CLAUDE.md at: $SOURCE_ROOT/CLAUDE.md"
    exit 1
fi

# --- Safety: don't bootstrap inside the source repo ---

TARGET_DIR="$(pwd)"

case "$TARGET_DIR" in
    "$SOURCE_ROOT"*)
        echo "Error: You're inside the source repo itself ($SOURCE_ROOT)."
        echo "cd to your study directory first, then run /where-is-god."
        exit 1
        ;;
esac

# --- Detect current state ---

ALREADY_BOOTSTRAPPED=false
if [ -f ".claude/commands/drill.md" ]; then
    ALREADY_BOOTSTRAPPED=true
fi

STUDY_EXISTS=false
if [ -d ".study" ]; then
    STUDY_EXISTS=true
fi

CLAUDEMD_STATUS="none"
if [ -f "CLAUDE.md" ]; then
    FIRST_LINE="$(head -1 CLAUDE.md)"
    if [ "$FIRST_LINE" = "<!-- study-with-claude -->" ]; then
        CLAUDEMD_STATUS="ours"
    else
        CLAUDEMD_STATUS="foreign"
    fi
fi

# --- Banner ---

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║    ⚡  G O D   O F   T H U N D E R   I S   H E R E  ⚡   ║"
echo "║                                                          ║"
echo "║         study-with-claude — exam prep activated           ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

if [ "$ALREADY_BOOTSTRAPPED" = true ]; then
    echo "Updating existing installation..."
    echo ""
fi

# --- Copy commands ---

mkdir -p .claude/commands
CMD_COUNT=0
for cmd_file in "$SOURCE_ROOT"/.claude/commands/*.md; do
    cp "$cmd_file" ".claude/commands/$(basename "$cmd_file")"
    CMD_COUNT=$((CMD_COUNT + 1))
done
echo "  [ok] $CMD_COUNT slash commands installed"

# --- Merge settings.local.json ---

SOURCE_SETTINGS="$SOURCE_ROOT/.claude/settings.local.json"
TARGET_SETTINGS=".claude/settings.local.json"

if [ ! -f "$TARGET_SETTINGS" ]; then
    cp "$SOURCE_SETTINGS" "$TARGET_SETTINGS"
    echo "  [ok] settings.local.json installed"
else
    # Signal to the prompt that merge is needed
    echo "  [merge] settings.local.json exists — needs merge"
    echo "__MERGE_SETTINGS__"
    echo "SOURCE=$SOURCE_SETTINGS"
    echo "TARGET=$TARGET_SETTINGS"
fi

# --- Copy .study-tools ---

mkdir -p .study-tools
cp "$SOURCE_ROOT/.study-tools/render.sh" .study-tools/render.sh
cp "$SOURCE_ROOT/.study-tools/template.html" .study-tools/template.html
chmod +x .study-tools/render.sh
echo "  [ok] .study-tools/render.sh + template.html"

# --- Copy .context/ ---

if [ -d "$SOURCE_ROOT/.context" ]; then
    mkdir -p .context
    for ctx_file in "$SOURCE_ROOT"/.context/*.md; do
        [ -f "$ctx_file" ] && cp "$ctx_file" ".context/$(basename "$ctx_file")"
    done
    echo "  [ok] .context/ architecture docs"
fi

# --- Handle CLAUDE.md ---

if [ "$CLAUDEMD_STATUS" = "none" ]; then
    cp "$SOURCE_ROOT/CLAUDE.md" ./CLAUDE.md
    echo "  [ok] CLAUDE.md installed"
elif [ "$CLAUDEMD_STATUS" = "ours" ]; then
    cp "$SOURCE_ROOT/CLAUDE.md" ./CLAUDE.md
    echo "  [ok] CLAUDE.md updated"
elif [ "$CLAUDEMD_STATUS" = "foreign" ]; then
    # Signal to the prompt that user input is needed
    echo "  [conflict] CLAUDE.md exists but is not from study-with-claude"
    echo "__CLAUDEMD_CONFLICT__"
    echo "SOURCE=$SOURCE_ROOT/CLAUDE.md"
fi

# --- Create directories ---

STUDY_CREATED=false
if [ ! -d ".study" ]; then
    STUDY_CREATED=true
fi
mkdir -p .study/rendered
mkdir -p .study/mock-exams

# --- Update .gitignore ---

GITIGNORE_STATUS="already present"
if [ ! -f ".gitignore" ]; then
    echo ".study/" > .gitignore
    GITIGNORE_STATUS="created"
elif ! grep -q "^\.study/$" .gitignore; then
    echo ".study/" >> .gitignore
    GITIGNORE_STATUS="added"
fi

# --- Summary ---

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Bootstrap complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Commands:  $CMD_COUNT slash commands"
echo "  Tools:     render.sh + template.html"

if [ "$CLAUDEMD_STATUS" = "foreign" ]; then
    echo "  CLAUDE.md: ⚠ conflict (see above)"
elif [ "$CLAUDEMD_STATUS" = "ours" ]; then
    echo "  CLAUDE.md: updated"
else
    echo "  CLAUDE.md: installed"
fi

if [ "$STUDY_CREATED" = true ]; then
    echo "  State:     .study/ created"
else
    echo "  State:     .study/ already existed (untouched)"
fi

echo "  Gitignore: .study/ $GITIGNORE_STATUS"
echo ""
echo "  Next steps:"
echo "    1. Add your study materials to module folders"
echo "    2. Run /init-session to scan and set up"
echo ""
echo "  Ready to study!"
echo ""
