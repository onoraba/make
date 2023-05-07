r=/home/user
sdir=$(r)/src
bdir=$(r)/build
void=$(r)/void-packages

qemu_%: out=$(r)/$@_$(tag)

define usage
targets:
qemu_arcan - arcan patch
qemu_arcan6 - v6.2.0 arcan patch, no submodules patched
qemu_arcan7 - v7.2.0 arcan patch, no submodules patched
qemu_arcan_fork7 - v7.2.0 cipharius arcan patch
qemu_min - v2.6.0
qemu_last - v7.2.0
qemu_3dfx - v7.2.0 3dfx patch
qemu_norm - v7.2.0 long term
arcan_git - built xbps pkgs with git master as source
endef
export usage

define xbps_out
############
run as root:
xbps-remove -y acfgfs aclip aloadimage arcan arcan-devel arcan_sdl durden xarcan
xbps-install --repository=$(void)/hostdir/binpkgs acfgfs aclip aloadimage arcan arcan-devel arcan_sdl durden xarcan
endef
export xbps_out

all:
	@echo "$$usage" 

# libXxf86vm-devel for 3dfx
ifeq ($(shell test -e /sbin/xbps-install && echo -n yes),yes)
 pkg_install=/sbin/xbps-install acfgfs aclip aloadimage arcan arcan-devel arcan_sdl durden xarcan
else
 pkg_install=echo "not implemented" && exit 1
endif

arcan_pkg:
	@$(pkg_install)

test: arcan_pkg
	@echo ok

# for build test
define qemu_opts_min
--disable-werror \
--disable-virglrenderer \
--disable-sdl \
--disable-gtk \
--disable-opengl \
--disable-curses \
--disable-spice \
--disable-spice-protocol \
--disable-guest-agent
endef

# usual
define qemu_opts_norm
--disable-werror \
--enable-virglrenderer \
--enable-sdl \
--enable-gtk \
--enable-opengl \
--enable-curses \
--enable-spice \
--enable-spice-protocol \
--disable-guest-agent
endef

# ancient
define qemu_min_opts
--disable-werror \
--disable-sdl \
--disable-gtk \
--disable-opengl \
--disable-curses \
--disable-guest-agent
endef

#qemu_arcan: arcan_pkg
qemu_arcan: git=https://github.com/letoram/qemu
qemu_arcan: tag=master
qemu_arcan: qemu_targets=x86_64-softmmu
qemu_arcan: qemu_opts=$(qemu_opts_min)
qemu_arcan: python=/sbin/python3
qemu_arcan: patch=echo > /dev/null

qemu_arcan6: git=https://github.com/qemu/qemu
qemu_arcan6: tag=v6.2.0
qemu_arcan6: qemu_targets=x86_64-softmmu
qemu_arcan6: qemu_opts=$(qemu_opts_min)
qemu_arcan6: python=/sbin/python3
qemu_arcan6: patch=$(arcan)

qemu_arcan7: git=https://github.com/qemu/qemu
qemu_arcan7: tag=v7.2.0
qemu_arcan7: qemu_targets=x86_64-softmmu
qemu_arcan7: qemu_opts=$(qemu_opts_min)
qemu_arcan7: python=/sbin/python3
qemu_arcan7: patch=$(arcan)

qemu_arcan_fork7: git=https://github.com/cipharius/qemu
qemu_arcan_fork7: tag=arcan-patches-v7.2.0
qemu_arcan_fork7: qemu_targets=x86_64-softmmu
qemu_arcan_fork7: qemu_opts=$(qemu_opts_min)
qemu_arcan_fork7: python=/sbin/python3
qemu_arcan_fork7: patch=echo > /dev/null

qemu_min: git=https://github.com/qemu/qemu
qemu_min: tag=v2.6.0
qemu_min: qemu_targets=x86_64-softmmu
qemu_min: qemu_opts=$(qemu_min_opts)
qemu_min: python=/sbin/python2
qemu_min: patch=$(old)

qemu_last: git=https://github.com/qemu/qemu
qemu_last: tag=v7.2.0
qemu_last: qemu_targets=x86_64-softmmu
qemu_last: qemu_opts=$(qemu_opts_min)
qemu_last: python=/sbin/python3
qemu_last: patch=echo > /dev/null

qemu_3dfx: git=https://github.com/qemu/qemu
qemu_3dfx: tag=v7.2.0
qemu_3dfx: qemu_targets=x86_64-softmmu
qemu_3dfx: qemu_opts=$(qemu_opts_min)
qemu_3dfx: python=/sbin/python3
qemu_3dfx: patch=$(3dfx)

qemu_norm: git=https://github.com/qemu/qemu
qemu_norm: tag=v7.2.0
qemu_norm: qemu_targets=x86_64-softmmu
qemu_norm: qemu_opts=$(qemu_opts_norm)
qemu_norm: python=/sbin/python3
qemu_norm: patch=echo > /dev/null

define gitmodules
fgrep 'url =' .gitmodules | tr '\t' ' ' | sed 's|  *| |g' | rev | cut -d ' ' -f1 | rev | \
while read url; do \
ldir=$$(echo $$url | rev | sed -e 's|^/||' -e s'|^tig.||' | cut -d '/' -f1-2 | tr '/' '_' | rev); \
test ! -d $(sdir)/$$ldir && git clone $$url $(sdir)/$$ldir || echo > /dev/null; \
sed --in-place "s|$$url|file://$(sdir)/$$ldir|" .gitmodules; \
done && sed --in-place '/url/ s|^\(.*\)$$|\1\n\tshallow = true|' .gitmodules && \
git -c protocol.file.allow=always submodule update --init
endef

#git format-patch -n HEAD^ --stdout \
#git am -3 arcan.patch \

#git diff HEAD^ HEAD \
#git apply arcan.patch \

define arcan
test ! -d $(sdir)/letoram_qemu && \
git clone https://github.com/letoram/qemu $(sdir)/letoram_qemu || echo > /dev/null && \
cd $(sdir)/letoram_qemu && \
git diff HEAD^ HEAD -- . ':!meson' ':!dtc' ':!ui/keycodemapdb' ':!slirp' \
> $(bdir)/$@_$(tag)/arcan.patch && \
patch -d $(bdir)/$@_$(tag) -p1 -i arcan.patch
endef

define 3dfx
test ! -d $(sdir)/qemu-3dfx && \
git clone https://github.com/kjliew/qemu-3dfx.git $(sdir)/qemu-3dfx || echo > /dev/null && \
rsync -v -r $(sdir)/qemu-3dfx/qemu-0/hw/3dfx $(bdir)/$@_$(tag)/hw && \
rsync -v -r $(sdir)/qemu-3dfx/qemu-1/hw/mesa $(bdir)/$@_$(tag)/hw && \
patch -d $(bdir)/$@_$(tag) -p0 -i $(sdir)/qemu-3dfx/00-qemu720-mesa-glide.patch
endef

# git diff --no-index -- old new
define old_memfd
diff --git a/util/memfd.c b/util/memfd.c
index 7c40691..3636f0d 100644
--- a/util/memfd.c
+++ b/util/memfd.c
@@ -34,9 +34,7 @@

 #include "qemu/memfd.h"

-#ifdef CONFIG_MEMFD
-#include <sys/memfd.h>
-#elif defined CONFIG_LINUX
+#if defined CONFIG_LINUX && !defined CONFIG_MEMFD
 #include <sys/syscall.h>
 #include <asm/unistd.h>

endef
export old_memfd

define old_configure
diff --git a/configure b/configure
index c37fc5f..86bdcd6 100755
--- a/configure
+++ b/configure
@@ -3612,7 +3612,7 @@ fi
 # check if memfd is supported
 memfd=no
 cat > $$TMPC << EOF
-#include <sys/memfd.h>
+#include <sys/mman.h>

 int main(void)
 {
endef
export old_configure

define old
cd $(bdir)/$@_$(tag) && \
echo "$${old_memfd}" | git apply --reject --whitespace=fix && \
echo "$${old_configure}" | git apply --reject --whitespace=fix
endef

qemu_%: ldir=$(shell echo $(git) | rev | cut -d '/' -f1-2 | rev | tr '/' '_')

qemu_%:
	@test ! -d $(sdir) && mkdir $(sdir) || echo > /dev/null
	@test ! -d $(bdir) && mkdir $(bdir) || echo > /dev/null
	@echo > /dev/null
	@test ! -d $(sdir)/$(ldir) && git clone $(git) $(sdir)/$(ldir) || echo > /dev/null
	@test ! -d $(sdir)/$(ldir)_$(tag) && git -c advice.detachedHead=false \
	clone -b $(tag) --depth 1 file://$(sdir)/$(ldir) $(sdir)/$(ldir)_$(tag) && \
	cd $(sdir)/$(ldir)_$(tag) && \
	$(gitmodules) && cd roms/edk2 && \
	$(gitmodules) || echo no_modules > /dev/null
	@rm -rf $(bdir)/$@_$(tag)
	@cp -rf $(sdir)/$(ldir)_$(tag) $(bdir)/$@_$(tag)
	@$(patch)
	@cd $(bdir)/$@_$(tag) && mkdir build && cd build && \
        CFLAGS=-Wno-error ../configure --python=$(python) --prefix=$(out) \
        --target-list=$(qemu_targets) \
        $(qemu_opts)
	@cd $(bdir)/$@_$(tag)/build && \
        make -j8
	@test -d $(out) && rm -rf $(out) || echo > /dev/null
	@cd $(bdir)/$@_$(tag)/build && \
        make install

#### glued part with arcan xbps rebuild from git

http=http://127.0.0.1:3000
http_server=python3 -m http.server --directory /tmp/ --bind 127.0.0.1 3000
rev=6

http_start:
	@$(http_server) 2> /dev/null > /dev/null &

void_pkg: http_start
	@test ! -d $(void) && \
	git clone --depth 1 https://github.com/void-linux/void-packages $(void) || echo > /dev/null
	@test -d $(void) && \
	cd $(void) && ./xbps-src zap && ./xbps-src binary-bootstrap || echo > /dev/null

arcan_git: void_pkg arcan_build arcan_sign
	@pkill -f -- '$(http_server)'
	@echo "$$xbps_out" 

openal: version=$(shell cat $(void)/srcpkgs/arcan/template | grep '_versionOpenal=' | cut -d '=' -f2)
arcan: version_openal=$(shell cat $(void)/srcpkgs/$(@)/template | grep '_versionOpenal=' | cut -d '=' -f2)
arcan xarcan acfgfs aclip aloadimage durden: version=$(shell cat $(void)/srcpkgs/$(@)/template | grep 'version=' | cut -d '=' -f2)

arcan xarcan durden: distfile=$(@)-$(version).tar.gz
aclip acfgfs aloadimage: distfile=arcan-$(version).tar.gz

arcan xarcan acfgfs aclip aloadimage durden: commit=HEAD
#xarcan: commit=30acea8

define git_got
rm -rf /tmp/$(@)-$(version)* || echo > /dev/null 
git clone --depth 1 https://github.com/letoram/$(@) /tmp/$(@)-$(version)
cd /tmp/$(@)-$(version) && git fetch --depth=1 origin $(commit) && git checkout $(commit) || echo > /dev/null
rm -rf /tmp/$(@)-$(version)/.git
cd /tmp && tar cvfz $(@)-$(version).tar.gz $(@)-$(version)
endef

define xbps_edit
cd $(void)/srcpkgs/$(@) && git checkout HEAD -- template || echo > /dev/null
cd $(void)/srcpkgs/$(@) && \
hash=$$(openssl dgst -sha256 /tmp/$(distfile) | cut -d ' ' -f2); \
sed -i -e "s/revision=.*/revision=$(rev)/" \
-e '/checksum=".*[^"]$$/N' -e "s/checksum=.*/checksum=$$hash/" \
-e '/distfiles=".*[^"]$$/N' -e "s|distfiles=.*|distfiles='$(http)/$(distfile)'|" template || \
echo > /dev/null
endef

define xbps_edit_arcan
cd $(void)/srcpkgs/$(@) && git checkout HEAD -- template || echo > /dev/null
cd $(void)/srcpkgs/$(@) && \
hash=$$(openssl dgst -sha256 /tmp/$(distfile) | cut -d ' ' -f2); \
hash_openal=$$(openssl dgst -sha256 /tmp/openal-$(version_openal).tar.gz | cut -d ' ' -f2); \
sed -i -e "s/revision=.*/revision=$(rev)/" \
-e '/checksum=".*[^"]$$/N' -e "s/checksum=.*/checksum='$$hash $$hash_openal'/" \
-e '/distfiles=".*[^"]$$/N' -e "s|distfiles=.*|distfiles='$(http)/$(distfile) $(http)/openal-$(version_openal).tar.gz'|" template || \
echo > /dev/null
endef

arcan_build: durden aclip acfgfs aloadimage xarcan arcan
	@cd $(void) && \
	./xbps-src pkg -f arcan && \
	./xbps-src pkg -f xarcan && \
	./xbps-src pkg -f aloadimage && \
	./xbps-src pkg -f acfgfs && \
	./xbps-src pkg -f aclip && \
	./xbps-src pkg -f durden

arcan_sign: arcan_build
	@rm -rf /tmp/void.key && openssl genrsa -out /tmp/void.key || echo > /dev/null
	@xbps-rindex --sign --signedby void --privkey /tmp/void.key $(void)/hostdir/binpkgs
	@xbps-rindex --sign-pkg --privkey /tmp/void.key $(void)/hostdir/binpkgs/*.xbps

openal: void_pkg
	$(git_got)

arcan: void_pkg openal
	$(git_got)
	$(xbps_edit_arcan)
	@cd $(void) && rm -rf hostdir/sources/$(@)* || echo > /dev/null
	@cd $(void) && rm -rf hostdir/sources/openal* || echo > /dev/null

xarcan: arcan
	$(git_got)
	$(xbps_edit)
	@cd $(void) && rm -rf hostdir/sources/$(@)* || echo > /dev/null

aclip: xarcan
	$(xbps_edit)

acfgfs: aclip
	$(xbps_edit)

aloadimage: acfgfs
	$(xbps_edit)

durden: aloadimage
	$(git_got)
	$(xbps_edit)
	@cd $(void) && rm -rf hostdir/sources/$(@)* || echo > /dev/null
