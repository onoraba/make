SHELL = /bin/sh

dir=/etc/void
runlevel=default

check_dir:
	@test -f $(dir) && rm -rf $(dir) || exit 0
	@test -d $(dir) || mkdir $(dir)

alpine_init: | check_dir fun_cfg alpine_bridge alpine_dhcp
	@rc-service dhcp start

fun_cfg:
	@install -m 755 etc/fun.sh etc/cfg.sh $(dir)

alpine_bridge:
	@install -m 755 void/bridge/run $(dir)/bridge
	@install -m 755 void/bridge/finish $(dir)/nobridge
	@install -m 755 alpine/template /etc/init.d/bridge
	@rc-update add bridge $(runlevel)
	@echo alpine_bridge

alpine_dhcp:
	-@apk update
	@apk add dhcpcd
	@install -m 755 alpine/template /etc/init.d/dhcp
	@echo 'depend() { need bridge; }' >> /etc/init.d/dhcp
	@install -m 755 alpine/dhcp $(dir)/dhcp
	@install -m 755 void/dhcp/finish $(dir)/nodhcp
	@rc-update add dhcp $(runlevel)
	@echo alpine_dhcp

alpine_remove:
	-@rc-service dhcp stop
	-@rc-service bridge stop
	-@rc-update del bridge $(runlevel)
	-@rc-update del dhcp $(runlevel)
	-@rm -rf $(dir)
	-@rm -rf /etc/init.d/dhcp
	-@rm -rf /etc/init.d/bridge
