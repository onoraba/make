#!/usr/bin/env sh

br=out
uplink_dev=$(first_ether) # or manual
test -z "${uplink_dev}" && exit 1
br_self_vlan=202
vlans=212,215,2-5
