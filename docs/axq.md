# docs/axq.md

axq — queue client (UNIX socket). Append/insert jobs, inspect queue, and control flow.

---

## Commands
- `add <svg> <profiles>` append
- `add <index> <svg> <profiles>` insert at 1-based position
- `add <svg> <profiles> <index>` alternate insert form
- `list` show queue (may include virtual “swap” rows)
- `remove <n>` remove by index (queued items)
- `move <from> <to>` re-order
- `top <n>` → `move n 1`
- `bottom <n>` → move to end
- `status` JSON snapshot
- `pause` / `resume` (resume also clears setup gate)
- `cancel-current` SIGTERM to running axicli
- `swap-now` raise pen immediately + gate

---

## SVG base path
If `svg_base` is set, `axq add foo.svg ...` resolves to `<svg_base>/foo.svg`. Absolute or relative paths bypass it.

---

## Examples

```bash
axq add poster.svg base,pen/gel,color/blue
axq add 1 cover.svg base,pen/gel,color/black
axq list
axq optimize --dry-run
axq optimize
axq swap-now
axq resume
```
