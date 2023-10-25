# goal
IP access on host via bridge with self vlan != 1
and tuntaps for vms in this bridge.
On alpine and void linux via openrc and runit.

# settings
Init scripts require dir /etc/void to exist.
It must contain what inside etc dir here.

# runit on void
## Bridge
```
cp -r void/bridge /etc/sv
ln -s /etc/sv/bridge /var/service
```

