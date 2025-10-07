# docs/profiles.md

Profiles — tiny Python files with assignments; compose them in order to build the final config.

---

## Tags (labels only)
Place empty files to act as sortable tags:
- `pen/<type>.py` (e.g., `pen/gel.py`)
- `color/<name>.py` (e.g., `color/black.py`)

These enable queue grouping with `axq optimize`.

---

## Typical knobs

```python
# speed/slow.py
const_speed = True
speed_pendown = 15
accel = 50
```

```python
# speed/fast.py
const_speed = False
speed_pendown = 45
accel = 90
```

```python
# paper/a3.py
model = 2
clip_to_page = True
auto_rotate = True
```
