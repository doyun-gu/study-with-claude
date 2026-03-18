#!/usr/bin/env bash
# Render a .study/ markdown file to HTML with MathJax + marked.js
# Usage: bash .study-tools/render.sh .study/big-picture.md

set -euo pipefail

INPUT="$1"

if [ ! -f "$INPUT" ]; then
  echo "Error: File not found: $INPUT" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/template.html"

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: Template not found: $TEMPLATE" >&2
  exit 1
fi

# Ensure output directory exists
mkdir -p .study/rendered

# Output filename: strip path and change extension
BASENAME="$(basename "$INPUT" .md)"
OUTPUT=".study/rendered/${BASENAME}.html"

# Base64 encode the markdown content (portable across macOS and Linux)
if command -v base64 >/dev/null 2>&1; then
  B64=$(base64 < "$INPUT")
else
  echo "Error: base64 command not found" >&2
  exit 1
fi

# Inject base64 content into template
sed "s|{{BASE64_CONTENT}}|${B64}|" "$TEMPLATE" > "$OUTPUT"

echo "Rendered: $OUTPUT"

# Auto-open in browser
if [ "$(uname)" = "Darwin" ]; then
  open "$OUTPUT"
elif command -v wslview >/dev/null 2>&1; then
  wslview "$OUTPUT"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$OUTPUT"
fi
