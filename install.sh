#!/usr/bin/env bash
#
# install.sh — set up git-identity-switcher on your Mac.
#
# What it does:
#   1. Copies the three helper scripts to /usr/local/bin (or ~/bin if that's
#      on your PATH).
#   2. Creates ~/.git-identities.json from identities.example.json if it does
#      not already exist.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"

# ── Pick an install directory that is writable and on $PATH ────────────────
if [ -w /usr/local/bin ]; then
  INSTALL_DIR="/usr/local/bin"
elif echo "$PATH" | grep -qE "(^|:)${HOME}/bin(:|$)"; then
  INSTALL_DIR="${HOME}/bin"
  mkdir -p "$INSTALL_DIR"
else
  INSTALL_DIR="${HOME}/.local/bin"
  mkdir -p "$INSTALL_DIR"
  echo "NOTE: Make sure $INSTALL_DIR is on your PATH."
fi

# ── Install scripts ────────────────────────────────────────────────────────
for script in switch-identity.sh list-identities.sh get-current-identity.sh; do
  dest="${INSTALL_DIR}/${script%.sh}"
  cp "$SCRIPTS_DIR/$script" "$dest"
  chmod +x "$dest"
  echo "Installed: $dest"
done

# ── Create identities config if absent ────────────────────────────────────
IDENTITIES_FILE="${HOME}/.git-identities.json"
if [ ! -f "$IDENTITIES_FILE" ]; then
  cp "$REPO_DIR/identities.example.json" "$IDENTITIES_FILE"
  echo "Created: $IDENTITIES_FILE (edit this file with your own identities)"
else
  echo "Skipped: $IDENTITIES_FILE already exists"
fi

# ── Optional: install the SwiftBar menu bar plugin ─────────────────────────
SWIFTBAR_DIR="$(defaults read com.ameba.SwiftBar PluginDirectory 2>/dev/null || true)"
if [ -n "$SWIFTBAR_DIR" ] && [ -d "$SWIFTBAR_DIR" ]; then
  cp "$REPO_DIR/menubar/git-identity.5s.sh" "$SWIFTBAR_DIR/"
  chmod +x "$SWIFTBAR_DIR/git-identity.5s.sh"
  echo "Installed menu bar plugin: $SWIFTBAR_DIR/git-identity.5s.sh (SwiftBar → Refresh)"
else
  echo "Menu bar (optional): install SwiftBar (brew install --cask swiftbar), then copy"
  echo "  menubar/git-identity.5s.sh into its plugin folder."
fi

echo ""
echo "✓ Installation complete."
echo ""
echo "Next steps:"
echo "  1. Edit ~/.git-identities.json and add your personal and work identities."
echo "  2. Test with: switch-identity personal"
echo "  3. Import the Alfred workflow: open alfred-workflow/git-identity-switcher.alfredworkflow"
