#!/usr/bin/env bash
#
# get-current-identity.sh — print the currently active global git identity.

set -euo pipefail

NAME=$(git config --global user.name  2>/dev/null || echo "(not set)")
EMAIL=$(git config --global user.email 2>/dev/null || echo "(not set)")

echo "$NAME <$EMAIL>"
