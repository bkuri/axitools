# AxiTools Installation Refactoring Summary

## 🎯 Goal: Unified Installation Approach

### Problem Solved:
- Eliminated dual installation confusion (system vs user paths)
- Single source of truth for installation logic
- Consistent file locations across all installation methods

## 📁 New Directory Structure

### System Installation (PKGBUILD):
```
/usr/bin/axd, axq, axp, axr           # Binaries
/etc/axitools/examples/                # Config templates
  ├── axq.toml, axr.toml              # Config examples  
  └── profiles/                        # Profile examples
/usr/share/doc/axitools/               # Documentation
```

### User Installation (Makefile):
```
~/bin/axd, axq, axp, axr              # Binaries
~/.config/axitools/                   # Live configs
/etc/axitools/examples/ → copy to ~/.config/axitools/
```

## 🔧 Key Changes

### Makefile.new Features:
1. **Dual mode support**: Auto-detects user vs system install
2. **Standard paths**: Uses /usr for system, ~/.local for user
3. **Template separation**: Examples in /etc, live configs in ~/.config
4. **PKGBUILD compatibility**: Supports DESTDIR/PREFIX variables
5. **Better help**: Clear usage instructions

### PKGBUILD.new Features:
1. **Uses Makefile**: Calls `make install-server DESTDIR=$pkgdir ...`
2. **Single source of truth**: All install logic in Makefile
3. **Standard Arch paths**: Follows Arch Linux conventions
4. **makedepends**: Added `make` build dependency

## 🚀 Usage Examples

### For Arch Users:
```bash
pacman -S axitools-server axitools-client
# Installs to /usr/bin, /etc/axitools/examples/
```

### For Non-Arch Users:
```bash
make install-server    # User install
make install-server DESTDIR=/opt PREFIX=/usr SYSCONFDIR=/etc  # System install
```

### For Developers:
```bash
make -f Makefile.new install-server
# Installs to ~/.local/bin with live configs in ~/.config/
```

## ✅ Benefits Achieved

1. **No more confusion**: Single binary location (/usr/bin or ~/.local/bin)
2. **Single maintenance**: One Makefile handles both modes
3. **Proper separation**: Templates vs live configs
4. **Standard compliance**: Follows Arch Linux packaging standards
5. **Developer-friendly**: Still easy to work with from source

## 📝 Migration Steps

1. Review Makefile.new changes
2. Test PKGBUILD.new with makepkg
3. Replace current files if acceptable
4. Update documentation
5. Remove setup.sh (now redundant)