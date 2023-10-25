# goal
IP access on host via bridge with self vlan != 1
and tuntaps for vms in this bridge.
On alpine and void linux via openrc and runit.

# settings
Init scripts require dir /etc/void to exist.
It must contain what inside etc dir here.
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

# openrc on alpine
## bridge
```
cp void/bridge/run /etc/void/bridge
cp void/bridge/finish /etc/void/nobridge
cp alpine/bridge /etc/init.d
rc-update add bridge
rc-service bridge start
```
