## makefile targets
- qemu_arcan - arcan patch
- qemu_arcan6 - v6.2.0 arcan patch, no submodules patched
- qemu_arcan7 - v7.2.0 arcan patch, no submodules patched
- qemu_arcan_fork7 - v7.2.0 cipharius arcan patch
- qemu_min - v2.6.0
- qemu_last - v7.2.0
- qemu_3dfx - v7.2.0 3dfx patch
- qemu_norm - v7.2.0 long term
- arcan_git - xbps for arcan kakoune-arcan and qemu-arcan
- arcan_new - same as git, but with pull request ver

## runit services
### network
- br - make bridge, with or without slaves and self vlan
```
cp -r br /etc/sv/br_out_enp89s0_202
ln -s /etc/sv/br_out_enp89s0_202 /var/service/br
```
- dhcp - start dhcpcd on interface
```
cp -r dhcp /etc/sv/dhcp_out
ln -s /etc/sv/dhcp_out /var/service/dhcp
```
