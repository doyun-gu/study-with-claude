#!/bin/bash
# Extract text from PDF pages using pdftotext (poppler)
# Bypasses Claude's Read tool size limits for large PDFs
#
# Usage:
#   pdf-extract.sh <file.pdf> [start_page] [end_page]   — extract text from page range
#   pdf-extract.sh --info <file.pdf>                     — show PDF metadata + file size
#   pdf-extract.sh --toc <file.pdf>                      — extract first 15 pages (usually TOC)
#   pdf-extract.sh --check                               — verify pdftotext is installed

set -euo pipefail

# --- Check mode ---
if [ "${1:-}" = "--check" ]; then
  if command -v pdftotext &>/dev/null; then
    echo "pdftotext: $(which pdftotext)"
    pdftotext -v 2>&1 | head -1 || true
    exit 0
  else
    echo "pdftotext: NOT FOUND"
    echo "Install with:"
    echo "  macOS:  brew install poppler"
    echo "  Linux:  sudo apt install poppler-utils"
    exit 1
  fi
fi

# --- Require pdftotext ---
if ! command -v pdftotext &>/dev/null; then
  echo "ERROR: pdftotext not found. Install with: brew install poppler (macOS) or sudo apt install poppler-utils (Linux)" >&2
  exit 1
fi

# --- Parse mode ---
MODE="extract"
if [ "${1:-}" = "--info" ]; then
  MODE="info"
  shift
elif [ "${1:-}" = "--toc" ]; then
  MODE="toc"
  shift
fi

FILE="${1:?Usage: pdf-extract.sh [--info|--toc|--check] <file.pdf> [start_page] [end_page]}"

if [ ! -f "$FILE" ]; then
  echo "ERROR: File not found: $FILE" >&2
  exit 1
fi

case "$MODE" in
  info)
    # PDF metadata
    if command -v pdfinfo &>/dev/null; then
      pdfinfo "$FILE" 2>/dev/null || true
    fi
    # File size (macOS and Linux compatible)
    if [ "$(uname)" = "Darwin" ]; then
      SIZE=$(stat -f "%z" "$FILE")
    else
      SIZE=$(stat -c "%s" "$FILE")
    fi
    MB=$((SIZE / 1024 / 1024))
    echo "File size:          ${MB} MB (${SIZE} bytes)"
    # Classification
    PAGES=$(pdfinfo "$FILE" 2>/dev/null | grep "^Pages:" | awk '{print $2}' || echo "unknown")
    if [ "$PAGES" != "unknown" ]; then
      if [ "$SIZE" -ge 20971520 ] || [ "$PAGES" -ge 500 ]; then
        echo "Classification:     oversized (use TOC-first progressive scan)"
      elif [ "$SIZE" -ge 10485760 ] || [ "$PAGES" -ge 200 ]; then
        echo "Classification:     large (use pdftotext extraction)"
      else
        echo "Classification:     standard (use Read tool)"
      fi
    fi
    ;;
  toc)
    # Extract first 15 pages — table of contents is usually here
    pdftotext -f 1 -l 15 -layout "$FILE" -
    ;;
  extract)
    START="${2:-}"
    END="${3:-}"
    if [ -n "$START" ] && [ -n "$END" ]; then
      pdftotext -f "$START" -l "$END" -layout "$FILE" -
    elif [ -n "$START" ]; then
      pdftotext -f "$START" -layout "$FILE" -
    else
      pdftotext -layout "$FILE" -
    fi
    ;;
esac
