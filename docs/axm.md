# docs/axp.md

axp — compose small profile snippets to generate an AxiDraw config on the fly and run axicli.

---

## Concept
- Each profile is a tiny Python file with assignments (e.g., `speed_pendown = 45`).
- `axp <p1> <p2> -- plot file.svg` merges left→right; emits a cached `axidraw_conf.py` and runs `axicli --config <that>`.

---

## Examples
Cycle with gel + slow:

```bash
axp base pen/gel speed/slow -- cycle
```

Plot A3 fast:

```bash
axp base paper/a3 speed/fast -- plot my.svg
```

Manual moves:

```bash
axp base -- up
axp base -- down
```

---

## Profile search paths
- current working dir
- `~/.config/axitools/profiles`
- absolute paths work too
