#!/usr/bin/env bash
#
# switch-identity.sh — switch the global git identity to a named profile.
#
# Usage:
#   switch-identity.sh <identity-name>
#   switch-identity.sh <identity-name> --local    # scoped to the current repo only
#
# The identities file is read from ~/.git-identities.json by default, or from
# the path stored in the GIT_IDENTITIES_FILE environment variable.

set -euo pipefail

IDENTITIES_FILE="${GIT_IDENTITIES_FILE:-${HOME}/.git-identities.json}"
IDENTITY_NAME="${1:-}"
SCOPE="--global"

if [ "${2:-}" = "--local" ]; then
  SCOPE="--local"
fi

if [ -z "$IDENTITY_NAME" ]; then
  echo "Usage: switch-identity.sh <identity-name> [--local]" >&2
  exit 1
fi

if [ ! -f "$IDENTITIES_FILE" ]; then
  echo "Identities file not found: $IDENTITIES_FILE" >&2
  echo "Run install.sh or copy identities.example.json to $IDENTITIES_FILE" >&2
  exit 1
fi

IDENTITY_JSON=$(python3 - <<PYEOF
import json, sys

with open("$IDENTITIES_FILE") as f:
    data = json.load(f)

for identity in data.get("identities", []):
    if identity.get("name") == "$IDENTITY_NAME":
        print(identity["username"])
        print(identity["email"])
        sys.exit(0)

sys.exit(1)
PYEOF
) || {
  echo "Identity '$IDENTITY_NAME' not found in $IDENTITIES_FILE" >&2
  exit 1
}

GIT_USER_NAME=$(echo "$IDENTITY_JSON" | head -1)
GIT_USER_EMAIL=$(echo "$IDENTITY_JSON" | tail -1)

git config "$SCOPE" user.name  "$GIT_USER_NAME"
git config "$SCOPE" user.email "$GIT_USER_EMAIL"

echo "✓ Switched git identity ($SCOPE) to: $GIT_USER_NAME <$GIT_USER_EMAIL>"
