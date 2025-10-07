# docs/axr.md

axr — remote AxiDraw queue wizard (fzf + rsync over ssh)

---

## What it does
- Runs locally on your workstation (client).
- Talks to the remote plot server via SSH.
- Uses **fzf** for scalable selection:
  - multi-pick **local** SVGs
  - multi-pick **remote** profiles (from `~/.config/axitools/profiles`)
  - choose queue position (**append** or **insert before #n**)
- Uploads files with **rsync** to the server, then calls `axq add` remotely.

---

## Client dependencies
- `python`
- `fzf`
- `rsync`
- `openssh` (for `ssh`)

---

## Server dependencies
- `python` (≥3.11 recommended)
- `python-axidraw` (Evil Mad Scientist)
- `python-pyserial`
- `rsync`
- `systemd` (to run `axd` as a user service)

---

## Config (`~/.config/axr.toml`)

```toml
ssh_host = "user@remote-machine"
ssh_port = 22
remote_svg_base = "/home/user/plots"  # fallback; prefer axq status.svg_base
local_temp_dir = "/tmp/axr"           # remote temp dir used by uploads

# optional:
identity_file = ""                    # e.g. "~/.ssh/id_ed25519"
proxy_command = ""                    # e.g. "ssh -W %h:%p jumpbox"
require_ssh = false
allow_local = false

# local SVG discovery
svg_roots = ["."]                     # search roots
skip_globs = ["**/.git/**","**/.cache/**","**/drafts/**"]
```

---

## Usage
```bash
axr        # launches the wizard
```

## Flow

1. Connect & verify (axq status) → show remote svg_base

2. Pick local SVG(s) via fzf (multi)

3. Pick remote profiles via fzf (multi)

4. Load remote queue → choose append or insert before #n via fzf

5. Confirm → upload (rsync) → axq add → print job IDs

## Notes:

- When the server reports svg_base in axq status, axr passes only the filename to axq add.

- When inserting multiple files at index N, axr submits them in reverse order to preserve your chosen order.
