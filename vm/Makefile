SHELL = /bin/sh

%: .PHONY

# display
d ?= $(shell pgrep arcan >/dev/null && echo arcan || echo none)

# bridge, vlan, audio backend, memory, disk size, snapshot
b ?= out
v ?= 230
a ?= none
m ?= 256
s ?= 5G
snap ?= $(shell date +%Y%m%d)
u ?= -snapshot

vm = $(HOME)/vm
id = $(shell uuidgen)

serial2 = -chardev stdio,id=char0,signal=${signal} -serial chardev:char0
serial = -serial mon:stdio

storage = -drive id=root,file=$(disk),index=0,media=disk,if=none -device virtio-blk-pci,drive=root

# utf8 or long names problems with filenames in os
dir = /home/user/fat
fat = -blockdev driver=vvfat,node-name=fat,fat-type=32,label=fat,dir=$(dir),read-only=on -device virtio-blk-pci,drive=fat

random_src = -object rng-random,filename=/dev/chaoskey0,id=random -device virtio-rng-pci,rng=random

max_tt = 2

mac ?= BE:$(shell uuidgen | tr -d '-' | sed 's/../&:/g' | head -c 14 | tr '[a-z]' '[A-Z]')

# first available tuntap
define get_tt
w=$$(pgrep -a -f 'tap,id=net,ifname=.*' | sed -n 's/.*tap,id=net,ifname=\($(b)_v$(v)_i[0-9][0-9]*\),script=.*/\1/p' | cut -d 'i' -f2); \
a=$$(seq $(max_tt)); \
test -z $${w} && i=1 || \
i=$$(echo "$${w}\n$${a}" | sort -n | uniq -u | head -n 1); \
test -z $${i} && exit 0 || echo $(b)_v$(v)_i$${i};
endef

ifname ?= $(shell $(get_tt))

init:
	@test ! -d $(vm) && \
	mkdir -p $(vm)/iso $(vm)/data $(vm)/tmp || \
	exit 0

alpine_%: version = 3.18.0
alpine_%: version_short = v$(shell echo $(version) | cut -d'.' -f1,2)
alpine_%: type = $(shell echo $(@) | cut -d'_' -f2)
alpine_%: iso_file = alpine-$(type)-$(version)-x86_64.iso
alpine_%: data = $(vm)/data/$(iso_file).qcow2
alpine_%: iso_uri = https://dl-cdn.alpinelinux.org/alpine/$(version_short)/releases/x86_64/$(iso_file)
alpine_%: iso = $(vm)/iso/$(iso_file)

ros ros%: version = 7.9.1
ros ros%: data = $(vm)/data/chr-$(version).qcow2
ros%: data_tmp = $(vm)/data/chr-$(version).img
ros%: data_uri = https://download.mikrotik.com/routeros/$(version)/chr-$(version).img.zip

openbsd openbsd%: version = 7.3
openbsd openbsd%: version_short = $(shell echo $(version) | tr -d '.')
openbsd openbsd%: data = $(vm)/data/openbsd-$(version).qcow2
openbsd openbsd%: iso_file = cd$(version_short).iso
openbsd%: iso_uri = https://cdn.openbsd.org/pub/OpenBSD/$(version)/amd64/$(iso_file)
openbsd openbsd%: iso = $(vm)/iso/$(iso_file)

netbsd netbsd%: version = 9.3
netbsd netbsd%: data = $(vm)/data/netbsd-$(version).qcow2
netbsd%: iso_uri = https://cdn.netbsd.org/pub/NetBSD/NetBSD-$(version)/amd64/installation/cdrom/boot-com.iso
netbsd netbsd%: iso = $(vm)/iso/netbsd-$(version).iso

freebsd freebsd%: version = 13.2
freebsd freebsd%: data_file = FreeBSD-$(version)-RELEASE-amd64.qcow2
freebsd freebsd%: data = $(vm)/data/$(data_file)
freebsd%: data_tmp_file = $(data_file).xz
freebsd%: data_uri = https://download.freebsd.org/ftp/releases/VM-IMAGES/$(version)-RELEASE/amd64/Latest/$(data_tmp_file)

dragonflybsd dragonflybsd%: version = 6.4.0
dragonflybsd dragonflybsd%: data_file = dragonflybsd-$(version).qcow2
dragonflybsd dragonflybsd%: data = $(vm)/data/$(data_file)
dragonflybsd%: data_tmp_file = $(data_file).img.bz2
dragonflybsd%: data_uri = https://mirror-master.dragonflybsd.org/iso-images/dfly-x86_64-$(version)_REL.img.bz2

%: netrom =
%: storage = -drive id=root,file=$(data),index=0,media=disk,if=none -device virtio-blk-pci,drive=root
%: cdrom_boot = -drive file=$(iso),index=2,media=cdrom -boot d
%: cdrom = -drive file=$(iso),index=2,media=cdrom -boot c
%: machine = q35
%: control = -device usb-ehci,id=usb -device usb-kbd,bus=usb.0 -device usb-tablet,bus=usb.0
%: audio = -audiodev driver=$(a),id=sound,in.channels=0,out.channels=2,out.frequency=44100,out.format=s16 -device ac97,audiodev=sound
%bsd win98 win98%: machine = pc

#win98 win98%: storage = -drive id=root,file=$(data),index=0,media=disk,if=none -device ahci,id=ahci -device ide-hd,drive=root,bus=ahci.0

win98 win98%: storage = -drive id=root,file=$(data),index=0,media=disk,if=none -device lsi -device scsi-hd,drive=root
win98 win98%: control =


define qemu
 qemu-system-x86_64 -nodefaults \
 -machine $(machine),usb=on,smbus=off,dump-guest-core=off,vmport=off,sata=on \
 -cpu kvm64 -smp 1 -m $(m) -accel kvm \
 -display $(d) \
 -netdev tap,id=net,ifname=$(ifname),script=no,downscript=no -device virtio-net-pci,romfile=$(netrom),netdev=net,mac=$(mac) \
 -device virtio-vga \
 -uuid $(id)
endef

define qemu2
 qemu-system-x86_64 \
 -machine $(machine),hpet=off,usb=off,smbus=off,dump-guest-core=off,vmport=off,sata=off \
 -cpu kvm64 -smp 1 -m $(m) -accel kvm \
 -display $(d) \
 -netdev tap,id=net,ifname=$(ifname),script=no,downscript=no -device rtl8139,romfile=$(netrom),netdev=net,mac=$(mac) \
 -device virtio-vga \
 -uuid $(id)
endef

%_iso:
	@test ! -s $(iso) && curl -o $(iso) $(iso_uri) && \
	file $(iso) | fgrep -q '7-zip' && cd $(vm)/iso && 7z e $(iso) || exit 0 && \
	find $(vm)/iso -maxdepth 1 -not -iname "*.iso" -not -path $(vm)/iso -delete || exit 0
	@-mv '$(vm)/iso/Windows 98 Second Edition.iso' $(iso) 2> /dev/null || exit 0

%_data:
	@test ! -s $(data) && qemu-img create -f qcow2 $(data) $(s) && \
	echo $(data) | grep -q alpine && printf '%24s\n' | tr ' ' '#' && printf "diskless guest oneliner:\n%s\n" "echo -e 'n\np\n1\n\n\nw' | fdisk /dev/vda; sleep 1; mkdosfs /dev/vda1; mkdir -p /media/vda1; echo '/dev/vda1 /media/vda1 vfat rw 0 0' >> /etc/fstab; mount -a; setup-alpine; lbu commit" || exit 0

ros_data:
	@test ! -s $(data) && curl -o $(data_tmp).zip $(data_uri) && \
	unzip -u $(data_tmp).zip -d $(vm)/data/ && \
	qemu-img convert -f raw -O qcow2 $(data_tmp) $(data) || exit 0

freebsd_data:
	@test ! -s $(data) && curl -o $(vm)/data/$(data_tmp_file) $(data_uri) && \
	cd $(vm)/data && unxz $(data_tmp_file) || exit 0

dragonflybsd_data:
	@test ! -s $(data) && curl -o $(vm)/data/$(data_tmp_file) $(data_uri) && \
	cd $(vm)/data && bunzip2 $(data_tmp_file) && \
	qemu-img convert -f raw -O qcow2 $(data_file).img $(data) || exit 0

alpine_standard alpine_virt alpine_extended alpine_netboot:
	@$(qemu) $(storage) $(cdrom_boot) $(serial) $(random_src) $(audio) $(control) $(u)

alpines: | init alpine_standard_data alpine_standard_iso alpine_standard
	@exit 0

alpinev: | init alpine_virt_data alpine_virt_iso alpine_virt
	@exit 0

alpinee: | init alpine_extended_data alpine_extended_iso alpine_extended
	@exit 0

alpinen: | init alpine_netboot_data alpine_netboot_iso alpine_netboot
	@exit 0

ros: | init ros_data
	@$(qemu) $(storage) $(serial) $(u)

openbsd: | init openbsd_iso openbsd_data
	@$(qemu) $(storage) $(cdrom_boot) $(serial) $(u)

netbsd: | init netbsd_iso netbsd_data
	@$(qemu) $(storage) $(cdrom_boot) $(serial) $(u)

freebsd: | init freebsd_data
	@$(qemu) $(storage) $(serial) $(u)

dragonflybsd: | init dragonflybsd_data
	@$(qemu) $(storage) $(serial) $(u)

dfly dbsd: dragonflybsd
	@exit 0

nbsd: netbsd
	@exit 0

fbsd: freebsd
	@exit 0

alpine_voip: type = virt
alpine_voip: data = $(vm)/data/$(@).qcow2
alpine_voip: | init alpine_virt_data alpine_virt_iso
	@test ! -e $(data) && \
	cp $(vm)/data/$(iso_file).qcow2 $(data) || exit 0
	@$(qemu) $(storage) $(cdrom_boot) $(serial) $(random_src) $(control) $(u) \
	-drive id=data,file=/tmp/fat.img,index=2,media=disk,if=none -device virtio-blk-pci,drive=data

win98_patcher: ver = 0.8.50
win98_patcher: file = patcher9x-$(ver)-win32.zip
win98_patcher: uri = https://github.com/JHRobotics/patcher9x/releases/download/v$(ver)/$(file)
win98_patcher:
	@test ! -s $(vm)/tmp/patcher9x.exe && curl -o $(vm)/tmp/$(file) -L $(uri) && \
	unzip -u $(vm)/tmp/$(file) -d $(vm)/tmp || exit 0

win98_disk_c: img = /tmp/fat.img
win98_disk_c:
	@test ! -s $(img) && \
	echo 'drive c: file="$(img)" partition=1' > $(HOME)/.mtoolsrc && \
	dd if=/dev/zero of=$(img) bs=1M count=1000 && \
	mpartition -I -c -a c: && \
	mformat -v win98 c: && \
	mcopy $(vm)/tmp/patcher9x.exe c:patch.exe && \
	mdir c: || exit 0

win98 win98%: type = win98se_oem
win98 win98%: data = $(vm)/data/$(type).qcow2
win98 win98%: iso_file = $(type).iso
win98 win98%: iso_uri = https://dl.winworldpc.com/Abandonware%20Operating%20Systems/PC/Microsoft%20Windows/Windows%2098-ME/Microsoft%20Windows%2098%20Second%20Edition.7z
win98 win98%: iso = $(vm)/iso/$(iso_file)
win98 win98%: mon = $(vm)/tmp/win98.sock
win98 win98%: screen = /tmp/win98.ppm

win98d:
	@$(qemu2) $(cdrom_boot) $(control) \
	-chardev socket,id=monitor,path=$(mon),server=on,wait=off \
	-drive id=data,file=/tmp/fat.img,index=2,media=disk,format=raw,if=none -device lsi -device scsi-hd,drive=data \
	-monitor chardev:monitor $(u) -daemonize

win98:
	@$(qemu2) $(storage) $(cdrom) $(control) $(u)

win98_setup: | init win98_iso win98_data win98d win98_cdrom_boot win98_welcome_setup win98_disk_space win98_support_large win98_cdrom_boot2 win98_routine_check win98_begin_setup win98_prepare_dir win98_install_type win98_hdd_boot win98_user_info win98_lic win98_hdd_boot2 win98_bsod win98_hdd_boot3 win98_after_bsod win98_time win98_bsod2 win98_hdd_boot4 win98_after_bsod2
	@sleep 120
	@pkill -f -- '-uuid $(id)'
	@echo complete

# patch first
# https://github.com/JHRobotics/patcher9x
win98_setup2: | init win98_iso win98_data win98_patcher win98d win98_cd_cli win98_fdisk_start win98_fdisk win98_fdisk_part win98_fdisk_finish win98_cd_cli2 win98_cd_dwin win98_format win98_format_label win98_xcopy win98_patch
	@sleep 120
	@pkill -f -- '-uuid $(id)'
	@echo complete

# patch and disk first
win98_setup3: | init win98_iso win98_data win98_patcher win98_disk_c win98d win98_cd_cli win98_cd_tools win98_xcopy win98_patch
	@sleep 120
	@pkill -f -- '-uuid $(id)'
	@echo complete

p_%: x = $(shell echo $(@) | cut -d'_' -f2)
p_%: y = $(shell echo $(@) | cut -d'_' -f3)
p_%: color = $(shell echo $(@) | cut -d'_' -f4)
%: send = | socat UNIX-CONNECT:"$(mon)" -; sleep 0.37
%: 2mon = socat UNIX-CONNECT:"$(mon)" -; sleep 0.37

define sk
 echo sendkey $(1) | $(2mon); sleep 0.37
endef

define sks
 echo $(1) | sed 's/\B/\n/g' | while read c; do echo sendkey $${c} | $(2mon); sleep 0.37; done
endef

p_%:
	@while true; do \
	echo "screendump $(screen)" | $(2mon); \
	sleep 0.5; \
	test $$(convert $(screen) -format '%[hex:u.p{$(x),$(y)}]' info:-) = $(color) && break; \
	done;

win98_cdrom_boot: p_0_2_A8A8A8
	@$(call sk,2); $(call sk,kp_enter)

win98_cdrom_boot2: p_0_3_A8A8A8
	@$(call sk,2); $(call sk,kp_enter)

win98_hdd_boot: p_0_4_A8A8A8
	@$(call sk,kp_enter)

win98_hdd_boot2: p_0_5_A8A8A8
	@$(call sk,kp_enter)

win98_hdd_boot3: p_0_6_A8A8A8
	@$(call sk,kp_enter)

win98_hdd_boot4: p_0_7_A8A8A8
	@$(call sk,kp_enter)

win98_welcome_setup: | p_9_18_A8A8A8 p_8_18_0000A8
	@$(call sk,kp_enter)

win98_disk_space: p_36_192_A8A8A8
	@$(call sk,kp_enter)

win98_support_large: p_36_160_A8A8A8
	@$(call sk,down); $(call sk,kp_enter); $(call sk,kp_enter)

win98_routine_check: p_1_18_A8A8A8
	@$(call sk,kp_enter)

win98_begin_setup: p_231_156_00FFFF
	@$(call sk,kp_enter)

win98_prepare_dir: p_189_227_FF00FF
	@$(call sk,tab)
	@$(call sk,kp_enter)

win98_install_type: p_304_176_FF0000
	@$(call sk,kp_enter); $(call sk,kp_enter)
	@$(call sks,win98)
	@$(call sk,kp_enter); $(call sk,kp_enter); $(call sk,kp_enter)

win98_user_info: p_119_210_FF00FF
	@$(call sks,user)
	@$(call sk,kp_enter)
	@$(call sk,tab)
	@$(call sk,tab)
	@$(call sk,tab)
	@$(call sk,kp_enter)

win98_lic: p_98_130_FFFF00
	@$(call sks,rw9mgqr4g32wrr9tg7bh33gxb)
	@$(call sk,kp_enter)
	@$(call sk,kp_enter)

win98_bsod: | p_45_183_FFFFFF p_324_144_A8A8A8
	@echo system_reset | $(2mon)

win98_after_bsod: p_18_178_A8A8A8 
	@$(call sk,1); $(call sk,kp_enter)

win98_time: p_527_215_57A8A8 
	@$(call sk,tab); $(call sk,kp_enter)

win98_bsod2: | p_46_183_FFFFFF p_325_144_A8A8A8
	@echo system_reset | $(2mon)

win98_after_bsod2: p_19_178_A8A8A8 
	@$(call sk,1); $(call sk,kp_enter)

### patch first
win98_cd_cli: p_0_2_A8A8A8
	@$(call sk,2); $(call sk,2); $(call sk,kp_enter)

win98_cd_cli2: p_0_3_A8A8A8
	@$(call sk,2); $(call sk,2); $(call sk,kp_enter)

win98_fdisk_start: p_0_3_A8A8A8
	@$(call sks,fdisk); $(call sk,kp_enter)

win98_fdisk: p_551_290_FFFFFF
	@# yes
	@$(call sk,kp_enter)
	@# create part and drive
	@$(call sk,kp_enter)
	@# create primary
	@$(call sk,kp_enter)

win98_fdisk_part: p_560_146_FFFFFF
	@# max avai
	@$(call sk,kp_enter)

win98_fdisk_finish: p_72_178_FFFFFF
	@$(call sk,esc)
	@echo system_reset | $(2mon)

# this one is long to run
win98_cd_dwin: p_0_4_A8A8A8
	@$(call sk,d); $(call sk,shift-semicolon); $(call sk,kp_enter)
	@$(call sks,cd)
	@$(call sk,spc)
	@$(call sks,win98); $(call sk,kp_enter)

win98_format: p_0_130_A8A8A8
	@$(call sks,format)
	@$(call sk,dot)
	@$(call sks,com)
	@$(call sk,spc)
	@$(call sk,c); $(call sk,shift-semicolon)
	@$(call sk,spc)
	@$(call sk,slash); $(call sks,s)
	@$(call sk,kp_enter)
	@$(call sk,y)
	@$(call sk,kp_enter)

win98_format_label: | p_0_370_A8A8A8 p_261_370_A8A8A8
	@$(call sk,kp_enter)

win98_cd_tools: | p_0_3_A8A8A8
	@# d: and cd tools/oldmsdos
	@$(call sk,d); $(call sk,shift-semicolon); $(call sk,kp_enter)
	@$(call sks,cd); $(call sk,spc); \
	$(call sks,tools); $(call sk,backslash); $(call sks,oldmsdos); $(call sk,kp_enter)

win98_xcopy: | p_1_130_A8A8A8
	@# xcopy32 /s /e d:\win98 c:\dist
	@$(call sks,xcopy32)
	@$(call sk,spc)
	@$(call sk,slash); $(call sks,s)
	@$(call sk,spc)
	@$(call sk,slash); $(call sks,e)
	@$(call sk,spc)
	@$(call sk,d); $(call sk,shift-semicolon)
	@$(call sk,backslash)
	@$(call sks,win98)
	@$(call sk,spc)
	@$(call sk,c); $(call sk,shift-semicolon)
	@$(call sk,backslash)
	@$(call sks,dist)
	@$(call sk,kp_enter)
	@# is it dir from xcopy
	@$(call sk,d)

win98_patch: | p_1_386_A8A8A8 p_366_347_A8A8A8
	@$(call sk,c); $(call sk,shift-semicolon); $(call sk,kp_enter)
	@$(call sks,patch); $(call sk,kp_enter)

