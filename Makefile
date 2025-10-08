SHELL := /bin/bash

# ---- Installation Configuration -------------------------------------------------
# For development/user installs: make install-server
# For package builds: make install-server DESTDIR=/usr PREFIX=/usr SYSCONFDIR=/etc

DESTDIR    ?= $(HOME)
PREFIX     ?= $(HOME)/.local
SYSCONFDIR ?= $(DESTDIR)/.config

# ---- Paths (calculable from config) -------------------------------------------
BIN_DIR     := $(PREFIX)/bin
CONF_DIR    := $(SYSCONFDIR)/axitools
DOCDIR      := $(PREFIX)/share/doc/axitools
EXAMPLEDIR  := $(SYSCONFDIR)/axitools/examples
SYSTEMD_DIR := $(SYSCONFDIR)/systemd/user

# User config files (only created for user installs)
USER_CONF_DIR := $(HOME)/.config
AXQ_CONF      := $(USER_CONF_DIR)/axq.toml
AXR_CONF      := $(USER_CONF_DIR)/axr.toml
AXI_PROF      := $(USER_CONF_DIR)/axitools/profiles
USER_SYSTEMD_DIR := $(USER_CONF_DIR)/systemd/user

# Data directory for queue (only for user installs)
DATA_DIR    := $(HOME)/.local/share/axq
Q_DIRS      := $(DATA_DIR)/queue $(DATA_DIR)/working $(DATA_DIR)/done $(DATA_DIR)/fail $(DATA_DIR)/logs

# ---- Files in this repo --------------------------------------------------------
SRC_AXD   := bin/axd
SRC_AXP   := bin/axp
SRC_AXQ   := bin/axq
SRC_AXR   := bin/axr
SRC_UNIT  := dist/axd.service
SRC_BASE  := dist/profiles/base.py
SRC_AXQ_CONF := dist/examples/axq.toml
SRC_AXR_CONF := dist/examples/axr.toml

# Optional tag-only example profiles
SRC_PEN_GEL   := dist/profiles/pen/gel.py
SRC_COLOR_BLK := dist/profiles/color/black.py

# ---- Installation Mode Detection -----------------------------------------------
# System install if PREFIX is /usr or /usr/local, otherwise user install
SYSTEM_INSTALL := $(filter /usr%,$(PREFIX))

# ---- Phony targets ---------------------------------------------------------------
.PHONY: all install install-server install-client enable disable reload uninstall status dirs help

help:
	@echo "AxiTools Installation"
	@echo "====================="
	@echo ""
	@echo "User/Development Installation:"
	@echo "  make install-server     - Install server to user directories"
	@echo "  make install-client     - Install client to user directories"
	@echo "  make enable/disable/reload/status - Manage systemd service"
	@echo "  make uninstall         - Remove user installation"
	@echo ""
	@echo "System Installation (for packages):"
	@echo "  make install-server DESTDIR=/pkg PREFIX=/usr SYSCONFDIR=/etc"
	@echo "  make install-client DESTDIR=/pkg PREFIX=/usr SYSCONFDIR=/etc"
	@echo ""
	@echo "Current config: PREFIX=$(PREFIX), SYSCONFDIR=$(SYSCONFDIR)"
	@echo "Install mode: $(if $(SYSTEM_INSTALL),SYSTEM,USER)"

all: install

dirs:
	@echo "Creating directories..."
	@mkdir -p "$(BIN_DIR)" \
	  "$(EXAMPLEDIR)/profiles/pen" "$(EXAMPLEDIR)/profiles/color" "$(EXAMPLEDIR)/profiles/speed" "$(EXAMPLEDIR)/profiles/paper" "$(EXAMPLEDIR)/profiles/ui" \
	  "$(SYSTEMD_DIR)" \
	  $(if $(SYSTEM_INSTALL),,$(Q_DIRS))
	@echo "✔ Directories created"

# Install server components (axd, axq, axp)
install-server-core: dirs
	@echo "Installing server binaries..."
	@install -Dm755 "$(SRC_AXD)" "$(BIN_DIR)/axd"
	@install -Dm755 "$(SRC_AXQ)" "$(BIN_DIR)/axq"
	@install -Dm755 "$(SRC_AXP)" "$(BIN_DIR)/axp"
	
	@echo "Installing systemd unit..."
	@install -Dm644 "$(SRC_UNIT)" "$(SYSTEMD_DIR)/axd.service"
	
	@echo "Installing documentation and examples..."
	@install -Dm644 README.md "$(DOCDIR)/README.md"
	@install -Dm644 docs/axr.md "$(DOCDIR)/axr.md"
	
	@# Example profiles
	@install -Dm644 "$(SRC_BASE)" "$(EXAMPLEDIR)/profiles/base.py"
	@if [ -f "$(SRC_PEN_GEL)" ]; then install -Dm644 "$(SRC_PEN_GEL)" "$(EXAMPLEDIR)/profiles/pen/gel.py"; fi
	@if [ -f "$(SRC_COLOR_BLK)" ]; then install -Dm644 "$(SRC_COLOR_BLK)" "$(EXAMPLEDIR)/profiles/color/black.py"; fi
	
	@# Example configs
	@install -Dm644 "$(SRC_AXQ_CONF)" "$(EXAMPLEDIR)/axq.toml"
	@install -Dm644 "$(SRC_AXR_CONF)" "$(EXAMPLEDIR)/axr.toml"
	
	@echo "✔ Server installed to $(BIN_DIR) and $(EXAMPLEDIR)"

# User-specific setup (create live configs from examples)
setup-user-configs:
	@if [ -z "$(SYSTEM_INSTALL)" ]; then \
		echo "Setting up user configuration..."; \
		mkdir -p "$(USER_CONF_DIR)" "$(AXI_PROF)/pen" "$(AXI_PROF)/color" "$(AXI_PROF)/speed" "$(AXI_PROF)/paper" "$(AXI_PROF)/ui"; \
		\
		if [ ! -f "$(AXQ_CONF)" ]; then \
			cp "$(SRC_AXQ_CONF)" "$(AXQ_CONF)"; \
			echo "✔ Created $(AXQ_CONF)"; \
		else \
			echo "⚠ $(AXQ_CONF) already exists"; \
		fi; \
		\
		if [ ! -f "$(AXR_CONF)" ]; then \
			cp "$(SRC_AXR_CONF)" "$(AXR_CONF)"; \
			echo "✔ Created $(AXR_CONF)"; \
		else \
			echo "⚠ $(AXR_CONF) already exists"; \
		fi; \
		\
		if [ ! -f "$(AXI_PROF)/base.py" ]; then \
			cp "$(SRC_BASE)" "$(AXI_PROF)/base.py"; \
			echo "✔ Created $(AXI_PROF)/base.py"; \
		fi; \
		\
		if [ -f "$(SRC_PEN_GEL)" ] && [ ! -f "$(AXI_PROF)/pen/gel.py" ]; then \
			cp "$(SRC_PEN_GEL)" "$(AXI_PROF)/pen/gel.py"; \
			echo "✔ Created $(AXI_PROF)/pen/gel.py"; \
		fi; \
		\
		if [ -f "$(SRC_COLOR_BLK)" ] && [ ! -f "$(AXI_PROF)/color/black.py" ]; then \
			cp "$(SRC_COLOR_BLK)" "$(AXI_PROF)/color/black.py"; \
			echo "✔ Created $(AXI_PROF)/color/black.py"; \
		fi; \
	fi

# Install server (system-wide or user)
install-server: install-server-core setup-user-configs
	@if [ -z "$(SYSTEM_INSTALL)" ]; then \
		echo "Starting systemd service..."; \
		systemctl --user daemon-reload || true; \
		systemctl --user enable --now axd || true; \
		systemctl --user status axd --no-pager || true; \
		echo "✔ axitools server installed and axd started"; \
	else \
		echo "✔ axitools server installed (package mode)"; \
	fi

# Install client components (axr)
install-client:
	@echo "Installing client..."
	@mkdir -p "$(BIN_DIR)" "$(EXAMPLEDIR)"
	@install -Dm755 "$(SRC_AXR)" "$(BIN_DIR)/axr"
	@install -Dm644 docs/axr.md "$(DOCDIR)/axr.md"
	@install -Dm644 "$(SRC_AXR_CONF)" "$(EXAMPLEDIR)/axr.toml"
	@echo "✔ axr installed to $(BIN_DIR)"
	@if [ -z "$(SYSTEM_INSTALL)" ]; then \
		if [ ! -f "$(AXR_CONF)" ]; then \
			cp "$(SRC_AXR_CONF)" "$(AXR_CONF)"; \
			echo "✔ Created $(AXR_CONF)"; \
		else \
			echo "⚠ $(AXR_CONF) already exists"; \
		fi; \
	fi

# Legacy compatibility targets
install: install-server
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

uninstall:
	@echo "Removing axitools..."
	@rm -f "$(BIN_DIR)/axp" "$(BIN_DIR)/axq" "$(BIN_DIR)/axd" "$(BIN_DIR)/axr"
	@rm -f "$(SYSTEMD_DIR)/axd.service"
	@echo "✖ Removed binaries and systemd unit"
	@if [ -z "$(SYSTEM_INSTALL)" ]; then \
		echo "Data and configs left at:"; \
		echo "  - $(DATA_DIR)"; \
		echo "  - $(AXQ_CONF)"; \
		echo "  - $(AXR_CONF)"; \
		echo "  - $(AXI_PROF)"; \
	else \
		echo "System data and configs left in $(SYSCONFDIR)"; \
	fi