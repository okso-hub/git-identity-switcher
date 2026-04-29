#!/usr/bin/env bash
#
# package.sh — bundle the alfred-workflow/ directory into a .alfredworkflow file.
#
# Usage:
#   ./package.sh              # creates dist/git-identity-switcher.alfredworkflow
#   ./package.sh <version>    # e.g. ./package.sh 1.0.0

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="${1:-1.0.0}"
DIST_DIR="$REPO_DIR/dist"
OUTPUT="$DIST_DIR/git-identity-switcher-${VERSION}.alfredworkflow"

mkdir -p "$DIST_DIR"

# An .alfredworkflow file is a ZIP archive of the workflow directory contents.
(
  cd "$REPO_DIR/alfred-workflow"
  zip -r "$OUTPUT" . -x "*.DS_Store"
)

echo "✓ Created: $OUTPUT"
echo ""
echo "Double-click the file to install it in Alfred, or run:"
echo "  open \"$OUTPUT\""
