#!/bin/bash

# axitools setup script
# Installs axitools to user's home directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
HOME_DIR="${HOME}"
BIN_DIR="${HOME_DIR}/bin"
CONF_DIR="${HOME_DIR}/.config"
AXQ_CONF="${CONF_DIR}/axq.toml"
AXI_PROF="${CONF_DIR}/axitools/profiles"
SYSTEMD_DIR="${CONF_DIR}/systemd/user"
DATA_DIR="${HOME_DIR}/.local/share/axq"

# Source files (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_AXP="${SCRIPT_DIR}/bin/axp"
SRC_AXQ="${SCRIPT_DIR}/bin/axq"
SRC_AXD="${SCRIPT_DIR}/bin/axd"
SRC_UNIT="${SCRIPT_DIR}/dist/axd.service"
SRC_BASE="${SCRIPT_DIR}/dist/profiles/base.py"
SRC_PEN_GEL="${SCRIPT_DIR}/dist/profiles/pen/gel.py"
SRC_COLOR_BLK="${SCRIPT_DIR}/dist/profiles/color/black.py"
SRC_CONF="${SCRIPT_DIR}/dist/axq.toml"

print_header() {
    echo -e "${BLUE}=== axitools Setup ===${NC}"
    echo "Installing axitools to your home directory..."
    echo
}

print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

check_dependencies() {
    echo "Checking dependencies..."

    if ! command -v python3 &> /dev/null; then
        print_error "python3 is required but not installed"
        exit 1
    fi

    if ! python3 -c "import tomllib" 2>/dev/null; then
        print_warning "tomllib not available, using fallback tomli"
    fi

    print_step "Dependencies checked"
}

create_directories() {
    echo "Creating directories..."

    mkdir -p "$BIN_DIR" \
        "$AXI_PROF"/{pen,color,speed,paper,ui} \
        "$SYSTEMD_DIR" \
        "$DATA_DIR"/{queue,working,done,fail,logs}

    print_step "Directories created"
}

install_binaries() {
    echo "Installing executables..."

    if [[ ! -f "$SRC_AXP" ]]; then
        print_error "Source file not found: $SRC_AXP"
        exit 1
    fi

    cp "$SRC_AXP" "$BIN_DIR/axp"
    cp "$SRC_AXQ" "$BIN_DIR/axq"
    cp "$SRC_AXD" "$BIN_DIR/axd"

    chmod +x "$BIN_DIR"/{axp,axq,axd}

    print_step "Executables installed to $BIN_DIR"
}

install_systemd_service() {
    echo "Installing systemd user service..."

    if [[ -f "$SRC_UNIT" ]]; then
        cp "$SRC_UNIT" "$SYSTEMD_DIR/axd.service"
        print_step "Systemd service installed"
    else
        print_warning "Systemd service file not found: $SRC_UNIT"
    fi
}

install_config() {
    echo "Setting up configuration..."

    if [[ ! -f "$AXQ_CONF" ]]; then
        if [[ -f "$SRC_CONF" ]]; then
            cp "$SRC_CONF" "$AXQ_CONF"
            print_step "Configuration copied from template"
        else
            # Create default config
            cat > "$AXQ_CONF" << EOF
bind = "127.0.0.1:8787"
token = "change-me-long-random"
ntfy_url   = ""
ntfy_topic = "axq"
ntfy_token = ""
default_pause_between = true
svg_base = "$HOME_DIR/plots"
EOF
            print_step "Default configuration created"
        fi
    else
        print_warning "Configuration already exists: $AXQ_CONF"
    fi
}

install_profiles() {
    echo "Installing profile templates..."

    # Base profile
    if [[ ! -f "$AXI_PROF/base.py" ]] && [[ -f "$SRC_BASE" ]]; then
        cp "$SRC_BASE" "$AXI_PROF/base.py"
        print_step "Base profile installed"
    elif [[ -f "$AXI_PROF/base.py" ]]; then
        print_warning "Base profile already exists"
    fi

    # Example pen profile
    if [[ ! -f "$AXI_PROF/pen/gel.py" ]] && [[ -f "$SRC_PEN_GEL" ]]; then
        cp "$SRC_PEN_GEL" "$AXI_PROF/pen/gel.py"
        print_step "Example pen profile installed"
    fi

    # Example color profile
    if [[ ! -f "$AXI_PROF/color/black.py" ]] && [[ -f "$SRC_COLOR_BLK" ]]; then
        cp "$SRC_COLOR_BLK" "$AXI_PROF/color/black.py"
        print_step "Example color profile installed"
    fi
}

setup_path() {
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        print_warning "Add $BIN_DIR to your PATH to use axp, axq, axd commands"
        echo "Add this to your shell config (~/.bashrc, ~/.zshrc, etc.):"
        echo "export PATH=\"\$HOME/bin:\$PATH\""
        echo
    fi
}

print_next_steps() {
    echo
    echo -e "${BLUE}=== Installation Complete! ===${NC}"
    echo
    echo "Next steps:"
    echo "1. Edit configuration: $AXQ_CONF"
    echo "   - Set a secure token"
    echo "   - Configure ntfy settings (optional)"
    echo "   - Set svg_base path"
    echo
    echo "2. Install AxiDraw Python library:"
    echo "   pip install --user pyaxidraw"
    echo
    echo "3. Enable and start the daemon:"
    echo "   systemctl --user daemon-reload"
    echo "   systemctl --user enable --now axd"
    echo
    echo "4. Test the installation:"
    echo "   axq status"
    echo
    echo "5. Create some plots directory:"
    echo "   mkdir -p ~/plots"
    echo
    echo "See README.md for detailed usage instructions."
}

main() {
    print_header
    check_dependencies
    create_directories
    install_binaries
    install_systemd_service
    install_config
    install_profiles
    setup_path
    print_next_steps
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [--help]"
        echo "Installs axitools to your home directory"
        exit 0
        ;;
    *)
        main
        ;;
esac
