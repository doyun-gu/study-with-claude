#!/usr/bin/env bash
# new-subject.sh — Create a new subject from the template
#
# Usage:
#   bash scripts/new-subject.sh                  # Interactive mode
#   bash scripts/new-subject.sh "Linear Algebra"  # Quick mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$PROJECT_DIR/subjects/_template"
SUBJECTS_DIR="$PROJECT_DIR/subjects"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    study-with-claude · New Subject   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Get subject name
if [ $# -ge 1 ]; then
    SUBJECT_NAME="$1"
else
    echo -e "${YELLOW}What subject are you studying?${NC}"
    echo "  Examples: Linear Algebra, Organic Chemistry, Constitutional Law"
    echo ""
    read -rp "  Subject name: " SUBJECT_NAME
fi

if [ -z "$SUBJECT_NAME" ]; then
    echo "Error: Subject name cannot be empty."
    exit 1
fi

# Convert to directory name (lowercase, hyphens for spaces)
DIR_NAME=$(echo "$SUBJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
SUBJECT_PATH="$SUBJECTS_DIR/$DIR_NAME"

if [ -d "$SUBJECT_PATH" ]; then
    echo ""
    echo -e "${YELLOW}Subject '$DIR_NAME' already exists at:${NC}"
    echo "  $SUBJECT_PATH"
    echo ""
    echo "  Drop your materials into: $SUBJECT_PATH/materials/"
    exit 0
fi

# Optional details
echo ""
echo -e "${YELLOW}Optional details (press Enter to skip):${NC}"
echo ""
read -rp "  Subject code (e.g., MATH201): " SUBJECT_CODE
read -rp "  Exam date (YYYY-MM-DD): " EXAM_DATE
read -rp "  Semester (e.g., Spring 2026): " SEMESTER

# Create from template
echo ""
echo "Creating subject..."
cp -r "$TEMPLATE_DIR" "$SUBJECT_PATH"

# Update README.md with actual values
README="$SUBJECT_PATH/README.md"
sed -i '' "s/\[Subject Name\]/$SUBJECT_NAME/g" "$README"
sed -i '' "s/\[e\.g\., EE301, MATH201\]/${SUBJECT_CODE:-—}/g" "$README"
sed -i '' "s/\[e\.g\., 2026-05-15\]/${EXAM_DATE:-—}/g" "$README"
sed -i '' "s/\[e\.g\., Spring 2026\]/${SEMESTER:-—}/g" "$README"

# Update placeholder in all reference files
for f in "$SUBJECT_PATH"/*.md; do
    sed -i '' "s/\[Subject Name\]/$SUBJECT_NAME/g" "$f" 2>/dev/null || true
done

echo ""
echo -e "${GREEN}✓ Created: subjects/$DIR_NAME/${NC}"
echo ""
echo "  Directory structure:"
echo "  subjects/$DIR_NAME/"
echo "  ├── README.md"
echo "  ├── materials/          ← Drop your PDFs here"
echo "  ├── big-picture.md"
echo "  ├── equations.md"
echo "  ├── exam-prep.md"
echo "  ├── flashcards.md"
echo "  └── weak-areas.md"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Copy your lecture PDFs into subjects/$DIR_NAME/materials/"
echo "  2. Open the project in Claude Desktop"
echo "  3. Ask: \"Build big picture for $DIR_NAME\""
echo ""
