# git-identity-switcher

An Alfred workflow (+ standalone shell scripts) that lets you switch your global `git user.name` and `git user.email` between saved profiles with a single command — no more `vim ~/.gitconfig`.

---

## How it works

1. You keep a small JSON file (`~/.git-identities.json`) that lists your git profiles (name, email).
2. Type `gid` in Alfred — the active profile is marked with a `●` and shown first — pick a profile, press **Enter**.
3. `git config --global user.name` and `git config --global user.email` are updated instantly, and a macOS notification confirms the switch.

You can also use the scripts directly from the terminal without Alfred.

---

## Quick start

### 1 — Install the helper scripts

```bash
git clone https://github.com/okso-hub/git-identity-switcher.git
cd git-identity-switcher
chmod +x install.sh
./install.sh
```

`install.sh` copies the three helper scripts to `/usr/local/bin` (or `~/bin`) and creates `~/.git-identities.json` from the example file if it does not already exist.

### 2 — Edit `~/.git-identities.json`

Replace the example values with your real identities:

```json
{
  "identities": [
    {
      "name":     "personal",
      "username": "Jane Doe",
      "email":    "jane@personal.example.com"
    },
    {
      "name":     "work",
      "username": "Jane Doe",
      "email":    "jane.doe@company.example.com"
    }
  ]
}
```

You can add as many profiles as you like.

### 3 — Import the Alfred workflow

```bash
./package.sh          # creates dist/git-identity-switcher-1.0.0.alfredworkflow
open dist/git-identity-switcher-1.0.0.alfredworkflow   # installs into Alfred
```

Or just double-click the generated `.alfredworkflow` file in Finder.

Alfred shows an import dialog — pick a **Category** (e.g. Productivity) and click
**Import**. To update an already-installed copy, just import again: Alfred
recognises it by its bundle id and offers to replace it, so there is no need to
delete the old one first.

---

## Alfred workflow

| Step | Type | Description |
|------|------|-------------|
| Keyword | `gid` | Opens the identity picker |
| Script Filter | `list-identities.sh` | Fuzzy-searches your profiles |
| Run Script | `switch-identity.sh` | Applies the chosen identity |
| Notification | macOS notification | Confirms the switch |

### Customising the keyword

Open Alfred Preferences → Workflows → Git Identity Switcher and double-click the **Script Filter** object.  Change the keyword from `gid` to anything you prefer.

---

## CLI usage (without Alfred)

```bash
# Show the currently active global git identity
get-current-identity

# Switch to the "work" profile
switch-identity work

# Switch to "personal" (scoped to the current repo only)
switch-identity personal --local
```

---

## Menu bar (optional)

Show the active profile in the macOS menu bar and switch from a dropdown using
[SwiftBar](https://github.com/swiftbar/SwiftBar) (or xbar).

1. Install and launch SwiftBar:

   ```bash
   brew install --cask swiftbar
   open -a SwiftBar
   ```

2. On first launch SwiftBar asks you to **choose a plugin folder** — pick or
   create any folder (e.g. `~/.swiftbar`).

3. Install the plugin into that folder — just re-run `./install.sh`, which
   copies it automatically once SwiftBar is set up:

   ```bash
   ./install.sh
   ```

   (Or copy it manually: `cp menubar/git-identity.5s.sh "<your-plugin-folder>/"`.)

4. In SwiftBar, click **Refresh**.

The menu bar then shows `⑂ <profile>`; its dropdown lists all identities (active
one ticked) and switches on click. It refreshes every 5 seconds.

---

## Project structure

```
git-identity-switcher/
├── install.sh                  # copies scripts to PATH, creates config
├── package.sh                  # zips alfred-workflow/ into .alfredworkflow
├── identities.example.json     # template for ~/.git-identities.json
├── scripts/
│   ├── switch-identity.sh      # switch global (or local) git identity
│   ├── list-identities.sh      # Alfred Script Filter JSON output
│   └── get-current-identity.sh # print current git user.name + email
├── alfred-workflow/
│   └── info.plist              # Alfred workflow definition
└── menubar/
    └── git-identity.5s.sh      # SwiftBar/xbar menu bar plugin (optional)
```

---

## Requirements

- **macOS** with **Alfred 4 or 5** (Powerpack required for custom workflows)
- **Python 3** (ships with macOS 12+; otherwise install via Homebrew)
- **git**

---

## Adding a new identity

Edit `~/.git-identities.json` and add a new object to the `identities` array:

```json
{
  "name":     "freelance",
  "username": "Jane Doe",
  "email":    "jane@freelance.example.com"
}
```

No restart needed — Alfred and the CLI scripts read the file on every run.
