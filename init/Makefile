SHELL = /bin/sh

dir=/etc/void
runlevel=default

check_dir:
	@test -f $(dir) && rm -rf $(dir) || exit 0
	@test -d $(dir) || mkdir $(dir)

alpine: | check_dir fun_cfg alpine_bridge alpine_dhcp
	@rc-service dhcp start

fun_cfg:
	@install -m 755 etc/fun.sh etc/cfg.sh /etc/void

alpine_bridge:
	@install -m 755 void/bridge/run /etc/void/bridge
	@install -m 755 void/bridge/finish /etc/void/nobridge
	@install -m 755 alpine/template /etc/init.d/bridge
	@rc-update add bridge $(runlevel)

alpine_dhcp:
	@apk update || exit 0
	@apk add dhcpcd
	@install -m 755 alpine/template /etc/init.d/dhcp
	@echo 'depend() { need bridge; }' >> /etc/init.d/dhcp
	@install -m 755 alpine/dhcp /etc/void/dhcp
	@install -m 755 void/dhcp/finish /etc/void/nodhcp
	@rc-update add dhcp $(runlevel)
