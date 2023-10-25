SHELL = /bin/sh

dir=/opt/arcan
user=user
group=$(user)
tmp=/home/$(user)/arcan
as_user=chpst -u $(user):$(group) -U $(user):$(group)

arcan: | get clone_ext cmake make install
	@exit 0

get:
	@$(as_user) git clone --depth 1 https://github.com/letoram/arcan $(tmp)

clone_ext:
	@$(as_user) $(tmp)/external/git/clone.sh

cmake:
	@install -o $(user) -g $(group) -m 755 -d $(tmp)/build
	@$(as_user) cmake -B $(tmp)/build -S $(tmp)/src -DBUILD_PRESET="everything"

make:
	@$(as_user) make -j$$(nproc) -C $(tmp)/build

install:
	@make DESTDIR=$(dir) -j$$(nproc) -C $(tmp)/build install

build_pkgs:
	@apk add wayland wayland-dev wayland-protocols mesa-dev ffmpeg-dev file-dev freetype-dev xz-dev openal-soft-dev libusb-dev libvncserver-dev libxkbcommon-dev sqlite-dev vlc-dev sdl2-dev libxcb-dev xcb-util-dev xcb-util-wm-dev mupdf-dev harfbuzz-dev jbig2dec-dev gumbo-parser-dev openjpeg-dev espeak-dev tesseract-ocr-dev build-base pkgconf cmake

run_pkgs:
	@apk add mesa-dri-gallium mesa-va-gallium intel-media-driver libva-intel-driver linux-firmware-i915 wayland wayland-protocols mesa ffmpeg file freetype xz openal-soft libusb libvncserver libxkbcommon sqlite vlc sdl2 libxcb xcb-util xcb-util-wm mupdf harfbuzz jbig2dec gumbo-parser openjpeg espeak tesseract-ocr sqlite-libs

clean:
	-@rm -rf $(tmp)
	-@rm -rf $(dir)
