# goal
IP access on host via bridge with self vlan != 1
and tuntaps for vms in this bridge.
On alpine and void linux via openrc and runit.

# settings
Init scripts require dir /etc/void to exist.
It must contain what inside ```etc``` dir here.
Shell funtions in ```fun.sh```, and variables
for scripts in ```cfg.sh```:
```
br=out # bridge name
uplink_dev=$(first_ether) # or manual
test -z "${uplink_dev}" && exit 1
br_self_vlan=202 # bridge self vlan id
vlans=212,215,2-5 # comma separated, could be ranges
```

# runit on void
## bridge
```
cp -r void/bridge /etc/sv
ln -s /etc/sv/bridge /var/service
```
## dhcp
```
cp -r void/dhcp /etc/sv
ln -s /etc/sv/dhcp /var/service
```

# openrc on alpine

## bridge
```
cp void/bridge/run /etc/void/bridge
cp void/bridge/finish /etc/void/nobridge
cp alpine/template /etc/init.d/bridge
rc-update add bridge
rc-service bridge start
```
## dhcp
```
apk add dhcpcd
cp alpine/template /etc/init.d/dhcp
echo 'depend() { need bridge; }' >> /etc/init.d/dhcp
cp alpine/dhcp /etc/void/
cp void/dhcp/finish /etc/void/nodhcp
rc-update add dhcp
rc-service dhcp start
```
## lbu add
```
lbu add /etc/void/
lbu add /etc/init.d/dhcp
lbu add /etc/init.d/bridge
mount -o remount,rw /media/cfg
lbu commit
```
# caveats
In case of network boot with vlans, the whole chain must support them.
Didn't saw vlans in x86 desktop bios settings for pxe.
Tho servers usually support vlans on netboot.
Next be vlans in rpieeprom, uboot, ipxe, initrd, etc.

Easy way is to run ethernet ports in dual-mode from switches perspective.
Normal boot then tagged traffic, which brings some issues.
Dual-mode vlan_id only works in untagged manner, so
```
bridge vlan add dev eth0 vid 202 tagged master
```
becomes
```
bridge vlan add dev eth0 vid 202 pvid untagged master
```
