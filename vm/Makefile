SHELL = /bin/sh

%: .PHONY

# display
d ?= $(shell pgrep arcan >/dev/null && echo arcan || echo none)

# bridge, vlan, audio backend, memory, disk size
b ?= out
v ?= 230
a ?= none
m ?= 256
s ?= 5G

vm = /home/user/vm

serial_stdio1 = -chardev stdio,id=char0,signal=${signal} -serial chardev:char0
serial_stdio2 = -serial mon:stdio

mikrotik: disk = /vms/disks/chr-7.9.1.qcow2

storage = -drive id=root,file=$(disk),index=0,media=disk,if=none -device virtio-blk-pci,drive=root

cdrom = -drive file=$(iso),index=1,media=cdrom
cdrom_boot = $(cdrom) -boot d

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
	test ! -d $(vm) && \
	mkdir -p $(vm)/iso $(vm)/data $(vm)/tmp

alpine: version = 3.18.0
alpine: data = $(vm)/data/alpine-$(version).qcow2
alpine: version_short = v$(shell echo $(version) | cut -d'.' -f1,2)
alpine: iso_file = alpine-standard-$(version)-x86_64.iso
alpine: iso_uri = https://dl-cdn.alpinelinux.org/alpine/$(version_short)/releases/x86_64/$(iso_file)
alpine: iso = $(vm)/iso/$(iso_file)

alpine_init:
	test ! -s $(iso) && curl -o $(iso) $(iso_uri)
	test ! -s $(data) && qemu-img create -f qcow2 $(data) $(s)

alpine: | init alpine_init
	@qemu-system-x86_64 -nodefaults \
	-machine q35,usb=on,smbus=off,dump-guest-core=off,vmport=off,sata=on \
	-cpu kvm64 -smp 1 -m $(m) -accel kvm \
	-display $(d) \
	$(serial_stdio2) \
	-drive file=$(iso),index=1,media=cdrom -boot d \
	-netdev tap,id=net,ifname=$(ifname),script=no,downscript=no -device virtio-net-pci,romfile=,netdev=net,mac=$(mac) \
	$(random_src) \
	-drive id=root,file=$(data),index=0,media=disk,if=none -device virtio-blk-pci,drive=root \
	-audiodev driver=$(a),id=sound,in.channels=0,out.channels=2,out.frequency=44100,out.format=s16 -device ac97,audiodev=sound \
	-device usb-ehci,id=usb \
	-device usb-kbd,bus=usb.0 \
	-device usb-tablet,bus=usb.0 \
	-snapshot

mikrotik:
	@qemu-system-x86_64 -nodefaults \
	-machine q35,usb=on,smbus=off,dump-guest-core=off,vmport=off,sata=on \
	-cpu kvm64 -smp 1 -m $(m) -accel kvm \
	-display $(d) \
	$(serial_stdio2) \
	-netdev tap,id=net,ifname=$(ifname),script=no,downscript=no -device virtio-net-pci,romfile=,netdev=net,mac=$(mac) \
	$(storage) \
	-snapshot
