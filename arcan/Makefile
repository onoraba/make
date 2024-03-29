SHELL = /bin/sh

dir=/opt/arcan
user=user
group=$(user)
tmp=/home/$(user)/arcan
# apk add runit for chpst
as_user=chpst -u $(user):$(group) -U $(user):$(group)

arcan: | build_pkgs get clone_ext fix_fts cmake make install durden run_pkgs
	@exit 0

durden:
	@$(as_user) git clone --depth 1 https://github.com/letoram/durden $(tmp)/durden
	@cp -r $(tmp)/durden/durden /usr/share/arcan/appl/
	@install -m 755 $(tmp)/durden/distr/durden /usr/bin/durden
	@sed -i 's|/usr/share/$$applname|/usr/share/arcan/appl|' /usr/bin/durden

get:
	@$(as_user) git clone --depth 1 https://github.com/letoram/arcan $(tmp)

clone_ext:
	@$(as_user) $(tmp)/external/git/clone.sh

fix_fts:
	@sed -i $(tmp)/src/a12/CMakeLists.txt -e '/set(LIBRARIES/ a\\tfts'

cmake:
	@install -o $(user) -g $(group) -m 755 -d $(tmp)/build
	@$(as_user) cmake -B $(tmp)/build -S $(tmp)/src -DBUILD_PRESET="everything" -DCMAKE_INSTALL_PREFIX="/usr"

make:
	@$(as_user) make -j$$(nproc) -C $(tmp)/build

install:
	@make -j$$(nproc) -C $(tmp)/build install

#	@make DESTDIR=$(dir) -j$$(nproc) -C $(tmp)/build install

build_pkgs:
	@apk add wayland wayland-dev wayland-protocols mesa-dev ffmpeg-dev file-dev freetype-dev xz-dev openal-soft-dev libusb-dev libvncserver-dev libxkbcommon-dev sqlite-dev vlc-dev sdl2-dev libxcb-dev xcb-util-dev xcb-util-wm-dev mupdf-dev harfbuzz-dev jbig2dec-dev gumbo-parser-dev openjpeg-dev espeak-dev tesseract-ocr-dev build-base pkgconf cmake musl-fts-dev

run_pkgs:
	@apk add mesa-dri-gallium mesa-va-gallium intel-media-driver libva-intel-driver linux-firmware-i915 wayland wayland-protocols mesa ffmpeg file freetype xz openal-soft libusb libvncserver libxkbcommon sqlite vlc sdl2 libxcb xcb-util xcb-util-wm mupdf harfbuzz jbig2dec gumbo-parser openjpeg espeak tesseract-ocr sqlite-libs musl-fts

clean:
	-@rm -rf $(tmp)
	-@rm -rf $(dir)

# void build pkgs
# wayland wayland-devel wayland-protocols MesaLib-devel ffmpeg-devel file-devel freetype-devel liblzma-devel libopenal-devel libusb-devel libvncserver-devel libxkbcommon-devel sqlite-devel vlc-devel SDL2-devel xcb-util-devel xcb-util-wm-devel mupdf-devel harfbuzz-devel jbig2dec-devel gumbo-parser-devel libopenjpeg2-devel libespeak-ng-devel tesseract-ocr-devel leptonica-devel pkgconf cmake

# alpine xarcan plus pkgs
# apk add libbsd libbsd-dev xkbcomp xkbcomp-dev libxkbfile libxkbfile-dev libxfont2 libxfont2-dev font-util-dev libxcvt libxcvt-dev libtirpc libtirpc-dev libepoxy libepoxy-dev xcb-util-image xcb-util-image-dev
