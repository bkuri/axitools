# README.md

axq • axd • axp • axr — minimal AxiDraw headless queue with composable profiles, ntfy actions, safe pen swaps, and remote access.

---

## Why

- Compose tiny Python profile snippets (pen type, speed, paper…) with **axp** → one ephemeral `axidraw_conf.py`.
- Queue SVG plots with **axq** to a UNIX-socket daemon **axd** (std-lib only, Arch-friendly).
- Consistent gates between jobs (for page/pen change), raise servo safely, and push **ntfy** notifications with **Resume / Skip / Cancel** links.
- Optional **optimize**: group queued jobs by `pen/<type>` + `color/<name>` to reduce pen swaps.

---

## Features

- Profiles-as-building-blocks (no duped configs)
- Queue ops: `add`, `add <index>`, `list`, `remove <n>`, `move <from> <to>`, `top <n>`, `bottom <n>`
- Flow: `status`, `pause`, `resume`, `cancel-current`, `swap-now`
- Grouping: `optimize [--dry-run]` by pen/color tags
- Implicit `svg_base` for shorter `add` commands
- ntfy control links through a tiny built-in HTTP endpoint

---

## Quick start (Arch Linux)

1) Install dependencies:

```bash
yay -S axitools-server # install on the machine that has the AxiDraw plugged in
yay -S axitools-client # install on the remote machine (Optional)
```

2) Create folders:

```bash
mkdir -p ~/bin ~/.config/axitools/profiles/{pen,color,speed,paper,ui} \
         ~/.local/share/axq/{queue,working,done,fail,logs} \
         ~/.config/systemd/user
```

3) Put scripts (see `bin/` in this repo):
- `~/bin/axd` (daemon)
- `~/bin/axp` (profile combiner & runner)
- `~/bin/axq` (client)
- `~/bin/axr` (remote client)

4) Config:

```toml
# ~/.config/axq.toml
bind = "127.0.0.1:8787"
token = "change-me-long-random"
ntfy_url   = "https://ntfy.your.host"
ntfy_topic = "axitools"
ntfy_token = ""
default_pause_between = true
svg_base = "/home/bk/plots"
```

5) systemd user unit:

```ini
# ~/.config/systemd/user/axd.service
[Unit]
Description=AxiDraw queue daemon (axd)
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=%h/bin/axd
Restart=on-failure
RestartSec=2

[Install]
WantedBy=default.target
```

Enable:

```bash
systemctl --user daemon-reload
systemctl --user enable --now axd
systemctl --user status axd
```

6) Minimal profiles:

```python
# ~/.config/axitools/profiles/base.py
penlift = 3; pen_pos_up = 85; pen_pos_down = 20
speed_pendown = 25; speed_penup = 75; accel = 75
```

```python
# ~/.config/axitools/profiles/pen/gel.py
# tag-only profile (can be empty)
```

```python
# ~/.config/axitools/profiles/color/black.py
# tag-only profile (can be empty)
```
(Optional progress in CLI):

```python
# ~/.config/axitools/profiles/ui/progress.py
progress = True
```

---

## Usage

Append:

```bash
axq add art.svg base,pen/gel,color/black
```

Insert at index 1:

```bash
axq add 1 poster.svg base,pen/gel,color/blue
```

List / remove / move:

```bash
axq list
axq remove 2
axq move 3 1
axq top 4
axq bottom 1
```

Flow control:

```bash
axq status
axq pause
axq resume
axq cancel-current
axq swap-now
```

Grouping:

```bash
axq optimize --dry-run
axq optimize
```

Remote client:

```bash
# From a remote machine
axr # Launches wizard
```

---

## Notes

- Inkscape uses its own prefs; CLI/Python must set `penlift=3` for brushless lifts.
- `axp` composes profiles → ephemeral config; precedence remains **CLI > config** as in `axicli`.
- `axd` raises pen and gates between jobs; ntfy links hit `http://bind/control?token=...&cmd=resume|skip|cancel`.
- Arch users can install `axitools-client` and `axitools-server` from AUR.
- Use `axr` for remote plotting via SSH + rsync with an fzf-based wizard and seamless `axq` communication.
