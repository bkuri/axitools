# docs/axd.md

axd — stdlib-only daemon: runs jobs via axp, manages queue, gates between jobs, raises pen, sends ntfy.

---

## Behavior
- Watches `~/.local/share/axq/queue/*.json` (oldest mtime first).
- After each job: moves to `done/` or `fail/`, sets `last_tags`, schedules **swap** if `(pen,color)` changed.
- Always gates between jobs if `default_pause_between = true` (recommended).
- `swap-now` triggers a gate immediately (pen raised using next job’s profiles).

---

## Socket API (JSON line)
- `status`
- `list`
- `add {svg, profiles[], index?}`
- `remove {n}`
- `move {from, to}`
- `top {n}`, `bottom {n}`
- `pause`, `resume`
- `cancel_current`
- `swap_now`

---

## HTTP control (for ntfy links)
`GET /control?token=...&cmd=resume|skip|cancel`
- `resume`: clear gate
- `skip`: drop next queued job
- `cancel`: terminate current job
