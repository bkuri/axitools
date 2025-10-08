# Maintainer: bkuri <aur+axitools@bkuri.com>

pkgbase=axitools
pkgname=(axitools-server axitools-client)
pkgver=0.1.0
pkgrel=1
pkgdesc="Minimal AxiDraw headless queue: axd (daemon), axq (client), axp (profiles), axr (remote wizard)"
arch=(any)
url="https://github.com/bkuri/axitools"
license=(MIT)
backup=('etc/axitools/axq.toml' 'etc/axitools/axr.toml')
makedepends=(git make)
source=("git+${url}.git#tag=v${pkgver}"
        "axitools.install")
sha256sums=('SKIP'
            'SKIP')

# one unified post-install script for both split packages
install=axitools.install

prepare() {
  cd "${srcdir}/axitools"
  # nothing to build; plain Python scripts + Makefile
}

build() {
  cd "${srcdir}/axitools"
  # no-op (kept for future use)
}

package_axitools-server() {
  depends=(
    python
    axicli
    rsync
    systemd
  )
  optdepends=(
    'ntfy-sh: push notifications if you wire webhooks'
    'openssh: handy for admin via ssh'
  )
  install=axitools.install
  provides=(axitools axd axq axp)
  conflicts=(axitools)

  cd "${srcdir}/axitools"

  # Install via Makefile (system prefix + DESTDIR)
  make DESTDIR="${pkgdir}" PREFIX="/usr" install-server

  # License
  install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"

  # Systemd services
  install -Dm644 dist/axd.user.service   "$pkgdir/usr/lib/systemd/user/axd.service"
  install -Dm644 dist/axd.system.service "$pkgdir/usr/lib/systemd/system/axd.service"

  # Docs (server-flavored). If your Makefile already installs docs, you can drop this.
  install -Dm644 README.md                  "${pkgdir}/usr/share/doc/axitools-server/README.md"
  install -Dm644 docs/axr.md                "${pkgdir}/usr/share/doc/axitools-server/axr.md"

  # Examples
  install -Dm644 dist/examples/axq.toml     "${pkgdir}/usr/share/doc/axitools-server/examples/axq.toml"
  install -Dm644 dist/profiles/base.py      "${pkgdir}/usr/share/doc/axitools-server/examples/profiles/base.py"
  install -Dm644 dist/profiles/pen/gel.py   "${pkgdir}/usr/share/doc/axitools-server/examples/profiles/pen/gel.py"
  install -Dm644 dist/profiles/color/black.py "${pkgdir}/usr/share/doc/axitools-server/examples/profiles/color/black.py"
}

package_axitools-client() {
  depends=(
    python
    fzf
    rsync
    openssh
  )
  install=axitools.install
  provides=(axitools axr)
  conflicts=(axitools)

  cd "${srcdir}/axitools"

  # Install via Makefile (client target)
  make DESTDIR="${pkgdir}" PREFIX="/usr" install-client

  # License
  install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"

  # Docs (client-flavored)
  install -Dm644 docs/axr.md                "${pkgdir}/usr/share/doc/axitools-client/axr.md"
  install -Dm644 dist/examples/axr.toml     "${pkgdir}/usr/share/doc/axitools-client/examples/axr.toml"
}
