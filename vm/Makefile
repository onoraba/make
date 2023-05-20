SHELL = /bin/sh

%: .PHONY

display = $(shell pgrep arcan >/dev/null && echo arcan || echo none)

ifndef b
 b = out
endif

ifndef v
 v = 208
endif

serial_stdio1 = -chardev stdio,id=char0,signal=${signal} -serial chardev:char0
serial_stdio2 = -serial mon:stdio

disk = /vms/disks/alpine.qcow2
storage = -drive id=root,file=$(disk),index=0,media=disk,if=none -device virtio-blk-pci,drive=root

alpine_iso = /vms/iso/alpine-virt-3.17.3-x86_64.iso
cdrom = -drive file=$(alpine_iso),index=1,media=cdrom
cdrom_boot = $(cdrom) -boot d

net_dev = $(b)_v$(v)_i1
net = -netdev tap,id=net,ifname=$(net_dev),script=no,downscript=no -device virtio-net-pci,romfile=,netdev=net

# utf8 or long names problems with filenames in os
dir = /home/user/fat
fat = -blockdev driver=vvfat,node-name=fat,fat-type=32,label=fat,dir=$(dir),read-only=on -device virtio-blk-pci,drive=fat

max_tt = 2

#test -z $${i} && echo "bridge $(b), vlan $(v), no free tts" && exit 1 || exit 0; \

alpine:
	@w=$$(pgrep -a -f 'tap,id=net,ifname=.*' | sed -n 's/.*tap,id=net,ifname=\($(b)_v$(v)_i[0-9][0-9]*\),script=.*/\1/p' | cut -d 'i' -f2); \
	a=$$(seq $(max_tt)); \
	test -z $${w} && i=1 || \
	i=$$(echo "$${w}\n$${a}" | sort -n | uniq -u | head -n 1); \
	test -z $${i} && echo "bridge $(b), vlan $(v), no free tts" && exit 1; \
	mac=$$(uuidgen | tr -d '-' | sed 's/../&:/g' | head -c 17 | tr '[a-z]' '[A-Z]'); \
	qemu-system-x86_64 -nodefaults \
	-machine q35,usb=on,smbus=off,dump-guest-core=off,vmport=off,sata=on \
	-cpu kvm64 -smp 1 -m 256 -accel kvm \
	-display ${display} \
	$(serial_stdio2) \
	$(cdrom_boot) \
	-netdev tap,id=net,ifname=$(b)_v$(v)_i$${i},script=no,downscript=no -device virtio-net-pci,romfile=,netdev=net,mac=$${mac} \
	$(storage) \
	-snapshot

