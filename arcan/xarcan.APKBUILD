# Maintainer: user <user@local.host>
pkgname=xarcan
pkgver=0.6.7
pkgrel=0
pkgdesc="arcan xorg"
options="!strip"
url="https://divergent-desktop.org"
arch="x86 x86_64 aarch64"
license="void"
subpackages="$pkgname-doc"
checkdepends="bash"
source="$pkgname.tgz"
builddir="$srcdir/$pkgname"
makedepends="
	meson
	cmake
	pixman-dev
	libbsd-dev
	xkbcomp-dev
	libxkbfile-dev
	libxfont2-dev
	font-util-dev
	libxcvt-dev
	libtirpc-dev
	libepoxy-dev
	xcb-util-image-dev
	xcb-util-wm-dev
	"
giturl="https://github.com/letoram/xarcan"

export CFLAGS="${CFLAGS/-Werror=format-security/}"

snapshot() {
 local _tmp=$(mktemp -d)
 git clone --depth 1 $giturl "$_tmp"
 tar -zcf "$startdir/$pkgname.tgz" --transform "s|${_tmp:1}|$pkgname|" "$_tmp"
 rm -rf "$_tmp"
}

build() {
 cd "$builddir"
 meson setup --prefix /usr build
 meson compile -C build
}

package() {
 DESTDIR="$pkgdir" meson install -C "$builddir/build"
}

sha512sums="
e9a26899d45b8969fdcfcb24981a91579c34fe7db194eb4cf3e18e1783d70f0dd979bf3d765049affde5c9738ac9597ddecb47f6a5c41a08803260b3ec78e86f  xarcan.tgz
"
