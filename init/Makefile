SHELL = /bin/sh

dir ?= /etc/void
runlevel ?= default
os ?= alpine

# be non invasive to existing cfg
dir:
	@install -m 755 -d $(dir)

init: $(os)_init
	@exit 0

noinit: $(os)_noinit
	@exit 0

alpine_init: | dir fun_cfg alpine_bridge alpine_dhcp
	@rc-service dhcp start

fun_cfg:
	@install -m 755 etc/fun.sh etc/cfg.sh $(dir)

alpine_bridge:
	@install -m 755 alpine/bridge /etc/init.d/bridge
	@rc-update add bridge $(runlevel)

alpine_dhcp:
	-@apk add dhcpcd
	@install -m 755 alpine/dhcp /etc/init.d/dhcp
	@rc-update add dhcp $(runlevel)

alpine_noinit:
	-@rc-service dhcp stop
	-@rc-service bridge stop
	-@rc-update del bridge $(runlevel)
	-@rc-update del dhcp $(runlevel)
	-@rm -rf /etc/init.d/dhcp
	-@rm -rf /etc/init.d/bridge
