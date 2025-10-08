# Maintainer: bkuri <aur+axitools@bkuri.com>
pkgbase=axitools
pkgname=(axitools-server axitools-client)
pkgver=0.1.0
pkgrel=1
pkgdesc_server="Minimal AxiDraw headless queue: axd(axitools daemon), axq(client), axp(profile combiner), axr(remote fzf wizard)"
pkgdesc_client="AxiDraw remote fzf wizard for selecting and managing plots"
url="https://github.com/bkuri/axitools"
arch=(any)
license=(MIT)
makedepends=(git)
source=("git+${url}.git#tag=v${pkgver}"
        "axitools-server.install"
        "axitools-client.install")
sha256sums=('SKIP'
            '32878bb0abdfd9b0d85d497bf2920dc9b0bf84998ee148212b4a4491354ef996'
            '4b23c3e4891b8db783e5e6924a205df455f14bd824ae6029000cad4f67b440f8')

# common install locations
_bin=/usr/bin
_user_unit_dir=/usr/lib/systemd/user
_doc=/usr/share/doc

# NOTE: we intentionally do not install user config files (~/.config/...) from the package.
#       Provide examples under /usr/share/doc instead.

prepare() {
  cd "${srcdir}/axitools"
  # nothing to build; scripts are plain python
}

build() {
  cd "${srcdir}/axitools"
  # no-op; keep for future use
}

package_axitools-server() {
  pkgdesc="${pkgdesc_server}"
  depends=(
    python
    axicli
    rsync
    systemd
  )
  optdepends=(
    'ntfy-sh: push notifications (if you use webhook endpoints)'
    'openssh: handy for admin via ssh'
  )
  install=axitools-server.install

  cd "${srcdir}/axitools"

  # Binaries
  install -Dm755 bin/axd "${pkgdir}${_bin}/axd"
  install -Dm755 bin/axq "${pkgdir}${_bin}/axq"
  install -Dm755 bin/axp "${pkgdir}${_bin}/axp"

  # systemd user unit
  install -Dm644 dist/axd.service "${pkgdir}${_user_unit_dir}/axd.service"

  # Examples & docs
  install -Dm644 README.md "${pkgdir}${_doc}/axitools-server/README.md"
  install -Dm644 docs/axr.md "${pkgdir}${_doc}/axitools-server/axr.md"

  # Example profiles under doc
  install -Dm644 dist/profiles/base.py "${pkgdir}${_doc}/axitools-server/examples/profiles/base.py"
  install -Dm644 dist/profiles/pen/gel.py "${pkgdir}${_doc}/axitools-server/examples/profiles/pen/gel.py"
  install -Dm644 dist/profiles/color/black.py "${pkgdir}${_doc}/axitools-server/examples/profiles/color/black.py"

  # Example config templates
  install -Dm644 dist/axq.toml "${pkgdir}${_doc}/axitools-server/examples/axq.toml"
}

package_axitools-client() {
  pkgdesc="${pkgdesc_client}"
  depends=(
    python
    fzf
    rsync
    openssh
  )
  optdepends=(
    'python: for running axr (already required)'
  )
  install=axitools-client.install

  cd "${srcdir}/axitools"

  # Client binary
  install -Dm755 bin/axr "${pkgdir}${_bin}/axr"

  # Docs & example config
  install -Dm644 docs/axr.md "${pkgdir}${_doc}/axitools-client/axr.md"
  # Ship an example axr.toml in docs rather than writing to the user’s home
  install -Dm644 dist/examples/axr.toml "${pkgdir}${_doc}/axitools-client/examples/axr.toml"
}
