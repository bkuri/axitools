# docs/ntfy.md

ntfy integration

---

## Config

```toml
# ~/.config/axq.toml

ntfy_url   = "https://ntfy.your.host"
ntfy_topic = "axq"
ntfy_token = ""  # optional bearer
bind  = "127.0.0.1:8787"
token = "change-me-long-random"
default_pause_between = true
svg_base = "/home/bk/plots"
```

You’ll receive messages on start, done/failed, waiting-for-setup (with control links).

---

## Action buttons (if your server supports headers)

In `axd`’s `send_ntfy()`, add:

```python
headers['X-Actions'] = json.dumps([
  {"action":"view","label":"Resume","url":f"{base}/control?token={t}&cmd=resume"},
  {"action":"view","label":"Skip","url":f"{base}/control?token={t}&cmd=skip"},
  {"action":"view","label":"Cancel","url":f"{base}/control?token={t}&cmd=cancel"},
])
```
