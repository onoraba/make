# Maintainer: user <user@local.host>
pkgname=arcan
pkgver=0.6.7
pkgrel=0
pkgdesc="desktop engine"
options="suid !strip"
url="https://divergent-desktop.org"
arch="x86 x86_64 aarch64"
license="void"
subpackages="$pkgname-doc"
checkdepends="bash"
source="$pkgname.tgz"
builddir="$srcdir/$pkgname"
makedepends="
	cmake
	pkgconf
	coreutils
	wayland-dev
	wayland-protocols
	mesa-dev
	ffmpeg-dev
	file-dev
	freetype-dev
	xz-dev
	openal-soft-dev
	libusb-dev
	libvncserver-dev
	libxkbcommon-dev
	sqlite-dev
	vlc-dev
	sdl2-dev
	libxcb-dev
	xcb-util-dev
	xcb-util-wm-dev
	mupdf-dev
	harfbuzz-dev
	jbig2dec-dev
	gumbo-parser-dev
	openjpeg-dev
	espeak-dev
	tesseract-ocr-dev
	musl-fts-dev
	"
giturl="https://github.com/letoram/arcan"

export CFLAGS="${CFLAGS/-Werror=format-security/}"

snapshot() {
 local _arcan=$(mktemp -d)
 git clone --depth 1 $giturl "$_arcan"
 "$_arcan/external/git/clone.sh"
 sed -i "$_arcan/src/a12/CMakeLists.txt" -e '/set(LIBRARIES/ a\\tfts' # fts fix
 install -m 755 -d "$_arcan/build"
 tar -zcf "$startdir/$pkgname.tgz" --transform "s|${_arcan:1}|arcan|" "$_arcan"
 rm -rf "$_arcan"
}

build() {
 cmake -B "$builddir/build" -S "$builddir/src" -DBUILD_PRESET="everything" -DCMAKE_INSTALL_PREFIX="/usr"
 make -j$(nproc) -C "$builddir/build"
}

package() {
 make DESTDIR="$pkgdir" -j$(nproc) -C "$builddir/build" install
}

sha512sums="
111736e8e2d1f7e52fd145c3bbfad1635b89cee46224b54e26925cbc4fe6c42cbd8f9d4dffb8115e40a44918b3f027b51dfb5e368dbdd5511ae5eae3e3455506  arcan.tgz
"
