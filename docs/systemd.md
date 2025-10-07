# docs/systemd.md

Systemd user service for axd (recommended).

---

## Unit

```ini
# ~/.config/systemd/user/axd.service

[Unit]
Description=AxiDraw queue daemon

[Service]
ExecStart=%h/bin/axd
Restart=on-failure

[Install]
WantedBy=default.target
```

Enable:

```bash
systemctl --user daemon-reload
systemctl --user enable --now axd
systemctl --user status axd
```
