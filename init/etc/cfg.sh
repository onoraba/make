#!/usr/bin/env sh

br=out # bridge name
uplink_dev=$(first_ether) # or manual
test -z "${uplink_dev}" && exit 1
br_self_vlan=202 # bridge self vlan id
vlans=212,215,2-5 # comma separated, could be ranges
