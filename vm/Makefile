SHELL = /bin/sh

%: .PHONY

d ?= $(shell pgrep arcan >/dev/null && echo arcan || echo none)

# bridge, vlan, audio backend, memory
b ?= out
v ?= 230
a ?= none
m = 256

serial_stdio1 = -chardev stdio,id=char0,signal=${signal} -serial chardev:char0
serial_stdio2 = -serial mon:stdio

alpine: disk = /vms/disks/alpine.qcow2
alpine: iso = /vms/iso/alpine-standard-3.18.0-x86_64.iso
alpine: iso2 = /vms/iso/alpine-virt-3.17.3-x86_64.iso

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

alpine:
	@qemu-system-x86_64 -nodefaults \
	-machine q35,usb=on,smbus=off,dump-guest-core=off,vmport=off,sata=on \
	-cpu kvm64 -smp 1 -m $(m) -accel kvm \
	-display $(d) \
	$(serial_stdio2) \
	$(cdrom_boot) \
	-netdev tap,id=net,ifname=$(ifname),script=no,downscript=no -device virtio-net-pci,romfile=,netdev=net,mac=$(mac) \
	$(random_src) \
	$(storage) \
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
