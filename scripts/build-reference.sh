#!/usr/bin/env bash
# build-reference.sh — Trigger Claude to scan materials and rebuild reference docs
#
# Usage:
#   bash scripts/build-reference.sh                        # Build all subjects
#   bash scripts/build-reference.sh numerical-analysis     # Build one subject
#   bash scripts/build-reference.sh --list                 # List available subjects

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SUBJECTS_DIR="$PROJECT_DIR/subjects"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  study-with-claude · Build References    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# List subjects (excluding _template)
list_subjects() {
    local found=0
    for dir in "$SUBJECTS_DIR"/*/; do
        [ ! -d "$dir" ] && continue
        local name
        name=$(basename "$dir")
        [ "$name" = "_template" ] && continue

        local material_count
        material_count=$(find "$dir/materials" -type f \( -name "*.pdf" -o -name "*.md" -o -name "*.txt" -o -name "*.png" -o -name "*.jpg" \) 2>/dev/null | wc -l | tr -d ' ')

        if [ "$material_count" -gt 0 ]; then
            echo -e "  ${GREEN}●${NC} $name ($material_count files in materials/)"
        else
            echo -e "  ${YELLOW}○${NC} $name (no materials yet)"
        fi
        found=$((found + 1))
    done

    if [ "$found" -eq 0 ]; then
        echo "  No subjects found. Run: bash scripts/new-subject.sh"
    fi
}

# Check for --list flag
if [ "${1:-}" = "--list" ]; then
    echo "Subjects:"
    echo ""
    list_subjects
    echo ""
    exit 0
fi

# Check if Claude Code is available
if ! command -v claude &>/dev/null; then
    echo -e "${RED}Error: Claude Code CLI not found.${NC}"
    echo ""
    echo "This script triggers Claude to read your materials and generate reference files."
    echo ""
    echo "Alternative: Open this project in Claude Desktop and ask:"
    echo "  \"Build big picture for [subject-name]\""
    echo ""
    exit 1
fi

# Determine target subjects
TARGET="${1:-all}"
SUBJECTS=()

if [ "$TARGET" = "all" ]; then
    for dir in "$SUBJECTS_DIR"/*/; do
        [ ! -d "$dir" ] && continue
        name=$(basename "$dir")
        [ "$name" = "_template" ] && continue
        SUBJECTS+=("$name")
    done
else
    if [ ! -d "$SUBJECTS_DIR/$TARGET" ]; then
        echo -e "${RED}Subject not found: $TARGET${NC}"
        echo ""
        echo "Available subjects:"
        list_subjects
        echo ""
        exit 1
    fi
    SUBJECTS+=("$TARGET")
fi

if [ ${#SUBJECTS[@]} -eq 0 ]; then
    echo "No subjects found. Create one first:"
    echo "  bash scripts/new-subject.sh"
    exit 1
fi

# Process each subject
for subject in "${SUBJECTS[@]}"; do
    subject_path="$SUBJECTS_DIR/$subject"
    material_count=$(find "$subject_path/materials" -type f \( -name "*.pdf" -o -name "*.md" -o -name "*.txt" -o -name "*.png" -o -name "*.jpg" \) 2>/dev/null | wc -l | tr -d ' ')

    echo -e "${BLUE}Building references for: $subject${NC}"

    if [ "$material_count" -eq 0 ]; then
        echo -e "  ${YELLOW}⚠ No materials found in $subject/materials/ — skipping${NC}"
        echo "  Drop your PDFs there first, then re-run."
        echo ""
        continue
    fi

    echo "  Found $material_count files in materials/"
    echo "  Launching Claude Code..."
    echo ""

    # Run Claude with the build prompt
    cd "$PROJECT_DIR"
    claude --print "Read all files in subjects/$subject/materials/ and generate comprehensive reference documents. For each file below, read it fully and extract all key information:

1. Update subjects/$subject/big-picture.md with:
   - Complete topic overview with all concepts covered
   - Key definitions and theorems
   - Topic dependency map
   - Week-by-week summary (if materials are organized by week)

2. Update subjects/$subject/equations.md with:
   - Every important equation, grouped by topic
   - Variable definitions for each equation
   - When to use each equation
   - Common mistakes and pitfalls

3. Update subjects/$subject/exam-prep.md with:
   - Practice questions at Easy/Medium/Hard levels
   - Past paper patterns (if past papers are in materials)
   - Exam strategy recommendations

4. Update subjects/$subject/flashcards.md with:
   - Key term definitions as Q&A pairs
   - Important equations as cards
   - Concept understanding questions

Be thorough. Read every page. Miss nothing." 2>&1 || true

    echo ""
    echo -e "  ${GREEN}✓ Done: $subject${NC}"
    echo ""
done

echo -e "${GREEN}Reference build complete.${NC}"
echo ""
echo "Open the project in Claude Desktop to start studying."
echo "  Try: \"Quiz me on [subject]\" or \"Explain [concept]\""
echo ""
