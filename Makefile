SHELL := /bin/bash

# ---- Paths (home install) ----------------------------------------------------
HOME_DIR    ?= $(HOME)
BIN_DIR     ?= $(HOME_DIR)/bin
CONF_DIR    ?= $(HOME_DIR)/.config
AXQ_CONF    ?= $(CONF_DIR)/axq.toml
AXR_CONF    ?= $(CONF_DIR)/axr.toml
AXI_PROF    ?= $(CONF_DIR)/axitools/profiles
SYSTEMD_DIR ?= $(CONF_DIR)/systemd/user

DATA_DIR    ?= $(HOME_DIR)/.local/share/axq
Q_DIRS      := $(DATA_DIR)/queue $(DATA_DIR)/working $(DATA_DIR)/done $(DATA_DIR)/fail $(DATA_DIR)/logs

# ---- Files in this repo ------------------------------------------------------
SRC_AXD   := bin/axd
SRC_AXP   := bin/axp
SRC_AXQ   := bin/axq
SRC_AXR   := bin/axr
SRC_UNIT  := dist/axd.service
SRC_BASE  := dist/profiles/base.py

# Optional tag-only example profiles
SRC_PEN_GEL   := dist/profiles/pen/gel.py
SRC_COLOR_BLK := dist/profiles/color/black.py

# ---- Phony targets -----------------------------------------------------------
.PHONY: all install enable disable reload uninstall status dirs install-server install-client

help:
	@echo "Targets:"
	@echo "  make install-server  - install full server (axd, axq, axp, systemd)"
	@echo "  make install-client  - install client only (axr)"
	@echo "  make enable|disable|reload|status|uninstall - manage axd service"

all: install

dirs:
	@mkdir -p "$(BIN_DIR)" \
	  "$(AXI_PROF)/pen" "$(AXI_PROF)/color" "$(AXI_PROF)/speed" "$(AXI_PROF)/paper" "$(AXI_PROF)/ui" \
	  "$(SYSTEMD_DIR)" $(Q_DIRS)

install: dirs
	@install -Dm755 "$(SRC_AXD)"  "$(BIN_DIR)/axd"
	@install -Dm755 "$(SRC_AXQ)"  "$(BIN_DIR)/axq"
	@install -Dm755 "$(SRC_AXP)"  "$(BIN_DIR)/axp"
	@install -Dm644 "$(SRC_UNIT)" "$(SYSTEMD_DIR)/axd.service"
	@# example base profile (won't overwrite existing)
	@if [ ! -f "$(AXI_PROF)/base.py" ]; then install -Dm644 "$(SRC_BASE)" "$(AXI_PROF)/base.py"; fi
	@# example tag-only profiles (won't overwrite)
	@if [ -f "$(SRC_PEN_GEL)" ] && [ ! -f "$(AXI_PROF)/pen/gel.py" ]; then install -Dm644 "$(SRC_PEN_GEL)" "$(AXI_PROF)/pen/gel.py"; fi
	@if [ -f "$(SRC_COLOR_BLK)" ] && [ ! -f "$(AXI_PROF)/color/black.py" ]; then install -Dm644 "$(SRC_COLOR_BLK)" "$(AXI_PROF)/color/black.py"; fi
	@# example axq config (won't overwrite)
	@if [ ! -f "$(AXQ_CONF)" ]; then \
	  echo 'bind = "127.0.0.1:8787"'               > "$(AXQ_CONF)"; \
	  echo 'token = "change-me-long-random"'      >> "$(AXQ_CONF)"; \
	  echo 'ntfy_url   = ""'                      >> "$(AXQ_CONF)"; \
	  echo 'ntfy_topic = "axitools"'              >> "$(AXQ_CONF)"; \
	  echo 'ntfy_token = ""'                      >> "$(AXQ_CONF)"; \
	  echo 'default_pause_between = true'         >> "$(AXQ_CONF)"; \
	  echo 'svg_base = "$(HOME_DIR)/plots"'       >> "$(AXQ_CONF)"; \
	fi
	@echo "✔ Installed to $(BIN_DIR) and configured systemd unit in $(SYSTEMD_DIR)"

enable:
	@systemctl --user daemon-reload
	@systemctl --user enable --now axd
	@systemctl --user status axd --no-pager || true

disable:
	@systemctl --user disable --now axd || true

reload:
	@systemctl --user daemon-reload
	@systemctl --user restart axd
	@systemctl --user status axd --no-pager || true

status:
	@systemctl --user status axd --no-pager || true

uninstall: disable
	@rm -f "$(BIN_DIR)/axp" "$(BIN_DIR)/axq" "$(BIN_DIR)/axd" "$(BIN_DIR)/axr"
	@rm -f "$(SYSTEMD_DIR)/axd.service"
	@echo "✖ Removed binaries and systemd unit. Data and configs left at:"
	@echo "  - $(DATA_DIR)"
	@echo "  - $(AXQ_CONF)"
	@echo "  - $(AXR_CONF)"
	@echo "  - $(AXI_PROF)"

# Server: installs axd/axq/axp and systemd unit (axd.service)
install-server: dirs
	@$(MAKE) install
	@systemctl --user daemon-reload || true
	@systemctl --user enable --now axd || true
	@systemctl --user status axd --no-pager || true
	@echo "✔ axitools server installed and axd started"

# Client: installs axr only (and drops a default axr.toml if missing)
install-client:
	@mkdir -p "$(BIN_DIR)" "$(CONF_DIR)"
	@install -Dm755 "$(SRC_AXR)" "$(BIN_DIR)/axr"
	@if [ ! -f "$(AXR_CONF)" ]; then \
	  echo 'ssh_host = "user@remote-machine"'  >  "$(AXR_CONF)"; \
	  echo 'ssh_port = 22'                    >> "$(AXR_CONF)"; \
	  echo 'remote_svg_base = ""'             >> "$(AXR_CONF)"; \
	  echo 'local_temp_dir = "/tmp/axr"'      >> "$(AXR_CONF)"; \
	  echo 'identity_file = ""'               >> "$(AXR_CONF)"; \
	  echo 'proxy_command = ""'               >> "$(AXR_CONF)"; \
	  echo 'require_ssh = false'              >> "$(AXR_CONF)"; \
	  echo 'allow_local = false'              >> "$(AXR_CONF)"; \
	  echo 'svg_roots = ["."]'                >> "$(AXR_CONF)"; \
	  echo 'skip_globs = ["**/.git/**","**/.cache/**","**/drafts/**"]' >> "$(AXR_CONF)"; \
	fi
	@echo "✔ axr installed to $(BIN_DIR)"
