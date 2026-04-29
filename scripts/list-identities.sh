#!/usr/bin/env bash
#
# list-identities.sh — output available git identities as Alfred Script Filter JSON.
#
# Alfred passes the current query string as the first argument ($1).
# The script prints a JSON object that Alfred uses to populate its results list.
#
# The identities file is read from ~/.git-identities.json by default, or from
# the path stored in the GIT_IDENTITIES_FILE environment variable.

set -euo pipefail

IDENTITIES_FILE="${GIT_IDENTITIES_FILE:-${HOME}/.git-identities.json}"
QUERY="${1:-}"

if [ ! -f "$IDENTITIES_FILE" ]; then
  cat <<JSON
{"items":[{"title":"No identities file found","subtitle":"Run install.sh or copy identities.example.json to ${IDENTITIES_FILE}","valid":false,"icon":{"path":"icon.png"}}]}
JSON
  exit 0
fi

python3 - "$QUERY" "$IDENTITIES_FILE" <<'PYEOF'
import json, sys

query      = sys.argv[1].lower()
identities_file = sys.argv[2]

with open(identities_file) as f:
    data = json.load(f)

items = []
for identity in data.get("identities", []):
    name     = identity.get("name", "")
    username = identity.get("username", "")
    email    = identity.get("email", "")

    # Filter by query (matches name, username, or email)
    if query and query not in name.lower() and query not in username.lower() and query not in email.lower():
        continue

    items.append({
        "uid":          name,
        "title":        name.title(),
        "subtitle":     f"{username} <{email}>",
        "arg":          name,
        "autocomplete": name,
        "icon":         {"path": "icon.png"},
    })

if not items:
    items.append({
        "title":    f"No match for \"{sys.argv[1]}\"",
        "subtitle": "Try a different search term",
        "valid":    False,
    })

print(json.dumps({"items": items}))
PYEOF
