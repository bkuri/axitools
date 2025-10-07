# CRUSH.md - AxiTools Development Guide

## Build & Install Commands
- `make install` - Install to user directory (creates dirs, binaries, systemd unit)
- `make enable` - Enable and start systemd service
- `make disable` - Stop and disable systemd service
- `make reload` - Reload daemon and restart service
- `make status` - Check service status
- `make uninstall` - Remove binaries and systemd unit

## Code Structure & Style
- Python profiles: Simple assignment files (e.g., `speed_pendown = 45`)
- Bash scripts: Use functions, error handling with `set -e`, colored output
- Config: TOML format with sensible defaults
- Profile paths: CWD → ~/.config/axitools/profiles → absolute paths

## Key Conventions
- Profile naming: `pen/type.py`, `color/name.py`, `speed/slow.py`
- Error handling: Validate dependencies, graceful failure modes
- Security: Token-based auth for daemon control
- Naming: snake_case for vars/functions, kebab-case for CLI commands

## Dependencies
- Python 3+ with tomllib (or fallback tomli)
- pyaxidraw for actual plotting (optional for basic setup)
- systemd for daemon management
