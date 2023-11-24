#!/usr/bin/env sh

# list phys net devs as csv with type wifi or eth
devs() {
 find /sys/class/net \
 -mindepth 1 \
 -maxdepth 1 \
 -lname '*virtual*' \
 -prune -o \
 -exec sh -c "test -d {}/wireless && echo {},wifi || echo {},eth" \;
}

# check if net dev exist
dev_exist() {
 local dev="${1}"
 test -z "${dev}" && return 1
 ip -br link show dev "${dev}" 2> /dev/null > /dev/null && \
 return 0 || \
 return 1
}

# first ethernet by name sorting
first_ether() {
 devs | rev | cut -d '/' -f1 | rev | grep ',eth' | sort | head -n 1 | cut -d ',' -f1
}

# add bridge with uplink dev and self vlan
add_ubr() {
 local name="${1}"
 local dev="${2}"
 local vlan="${3}"

 test -z "${name}" && return 1
 test -z "${dev}" && return 1
 test -z "${vlan}" && return 1

 dev_exist "${dev}" || return 1 # no uplink
 dev_exist "${name}" && return 1 # already exist

 ip link add name "${name}" type bridge
 
 # flushing existing ips
 ip -4 addr flush dev "${dev}"
 ip -6 addr flush dev "${dev}"

 # link up and add to bridge
 ip link set up dev "${dev}"
 ip link set "${dev}" master "${name}"

 # tagged vlan on dev
 bridge vlan add dev "${dev}" vid "${vlan}" pvid master

 # enable vlan_filtering
 ip link set dev "${name}" type bridge \
  vlan_filtering 1 \
  vlan_default_pvid "${vlan}" \
  nf_call_iptables 0 \
  nf_call_arptables 0 \
  stp_state 0

 # link up bridge
 ip link set up dev "${name}"
}

# remove bridge with uplink
del_ubr() {
 local name="${1}"
 local dev="${2}"

 test -z "${name}" && return 1
 test -z "${dev}" && return 1

 dev_exist "${name}" || return 0 # already exist

 # flushing bridge ips
 ip -4 addr flush dev "${name}"
 ip -6 addr flush dev "${name}"

 # removing uplink and link on it
 ip link set "${dev}" nomaster
 ip link set "${dev}" down

 # removing bridge
 ip link set "${name}" down
 ip link del "${name}"
}

# add/remove tagged vlans to/from bridge uplink
uplink_vlans() {
 local op="${1}" # add or del
 local dev="${2}"
 local vlans="${3}"

 test -z "${dev}" && return 1
 test -z "${vlans}" && return 1

 dev_exist "${dev}" || return 1 # no uplink

 echo "${vlans}" | tr ',' '\n' | while read vid; do
  bridge vlan "${op}" dev "${dev}" vid "${vid}" tagged master
 done

#bridge vlan add dev ${dev} vid 1-${max_vlans} tagged master
#bridge vlan add dev ${bridge} vid 1-${max_vlans} self tagged
}

# add/del N tuntaps for each vlan
tuntaps() {
 local op="${1}"
 local bridge="${2}"
 local vlans="${3}"
 local count="${4-2}"
 local user="${5-user}"
 local mac_prefix="${6-aabb0}" # mac start with
 local vid2num="0f" # mac part that splits vid and num hexes

 test -z "${op}" && return 1
 test -z "${bridge}" && return 1
 test -z "${vlans}" && return 1
 test -z "${count}" && return 1
 test -z "${user}" && return 1

 echo "${vlans}" | tr ',' '\n' | while read vid; do
  case "${vid}" in
  *-*) seq $(echo "${vid}" | sed 's/-/ 1 /') ;;
  *) echo "${vid}" ;;
  esac
 done | while read vid; do
  case "${op}" in
  add)
   bridge vlan add dev "${bridge}" vid "${vid}" master
   seq "${count}" | while read num; do
    local tt="${bridge}_v${vid}_n${num}"
    ip tuntap add name "${tt}" mode tap user "${user}"
    local vid_hex=$(echo 00$(echo "obase=16;${vid}" | bc) | tail -c 4)
    local num_hex=$(echo 0$(echo "obase=16;${num}" | bc) | tail -c 3)
    local mac=$(echo "${mac_prefix}${vid_hex}0f${num_hex}" | sed 's/../:&/2g' | tr '[A-Z]' '[a-z]')
    ip link set "${tt}" address "${mac}"
    ip link set "${tt}" up
    ip link set "${tt}" master "${bridge}"
    bridge vlan del dev "${tt}" vid 1
    bridge vlan add dev "${tt}" vid "${vid}" pvid untagged master
   done
   ;;
  del)
   seq "${count}" | while read num; do
    local tt="${bridge}_v${vid}_n${num}"
    ip tuntap del name "${tt}" mode tap
   done
  ;;
  *) return 1 ;;
  esac
done

}
