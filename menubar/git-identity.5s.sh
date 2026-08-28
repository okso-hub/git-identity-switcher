#!/usr/bin/env bash
#
# git-identity.5s.sh — SwiftBar / xbar plugin.
#
# Shows the currently active global git identity in the macOS menu bar and
# lets you switch profiles from the dropdown. The refresh interval is encoded
# in the filename (".5s." = every 5 seconds).
#
# Install:
#   1. Install SwiftBar:  brew install --cask swiftbar   (or xbar)
#   2. On first launch, point SwiftBar at a plugin folder.
#   3. Copy this file into that folder (keep the ".5s.sh" name), then chmod +x.
#   4. SwiftBar → Refresh.
#
# The "Switch to …" menu entries call switch-identity, which install.sh places
# on your PATH. If it is not installed they are simply omitted.

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin:$PATH"

IDENTITIES_FILE="${HOME}/.git-identities.json"
ACTIVE_EMAIL="$(git config --global user.email 2>/dev/null)"
ACTIVE_NAME="$(git config --global user.name 2>/dev/null)"

SWITCH_BIN="$(command -v switch-identity || true)"

# ── Resolve the active profile label from the identities file ───────────────
PROFILE="?"
if [ -f "$IDENTITIES_FILE" ]; then
  PROFILE="$(python3 - "$IDENTITIES_FILE" "$ACTIVE_EMAIL" <<'PYEOF'
import json, sys
try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
except Exception:
    print("?"); sys.exit(0)
active = (sys.argv[2] if len(sys.argv) > 2 else "").strip().lower()
for i in data.get("identities", []):
    if i.get("email", "").lower() == active and active:
        print(i.get("name", "?")); sys.exit(0)
print("?")
PYEOF
)"
fi

# ── Menu bar title ──────────────────────────────────────────────────────────
echo "⑂ ${PROFILE}"
echo "---"
echo "Active git identity | size=11"
echo "${ACTIVE_NAME:-(not set)} <${ACTIVE_EMAIL:-(not set)}> | color=#888888 font=Menlo size=11"

# ── Quick switch entries ────────────────────────────────────────────────────
if [ -n "$SWITCH_BIN" ] && [ -f "$IDENTITIES_FILE" ]; then
  echo "---"
  echo "Switch to"
  python3 - "$IDENTITIES_FILE" "$ACTIVE_EMAIL" "$SWITCH_BIN" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
active = (sys.argv[2] if len(sys.argv) > 2 else "").strip().lower()
switch = sys.argv[3]
for i in data.get("identities", []):
    name  = i.get("name", "")
    email = i.get("email", "")
    mark  = "✓ " if email.lower() == active and active else "  "
    # bash=... runs switch-identity; refresh=true re-renders the menu bar
    print(f"--{mark}{name} | bash={switch} param1={name} terminal=false refresh=true")
PYEOF
fi

echo "---"
echo "Edit identities… | bash=/usr/bin/open param1=${IDENTITIES_FILE} terminal=false"
echo "Refresh | refresh=true"
