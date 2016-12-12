#!/bin/sh

#/etc/init.d/firewall disable

cp /root/xFengx/rc.local /etc/
chmod +x /etc/rc.local

uci delete system.@button[0]
uci delete system.@button[0]
uci delete system.@button[0]
uci commit system

uci add system button
uci set system.@button[-1].button=wps
uci set system.@button[-1].action=released
uci set system.@button[-1].handler="cd /root/xFengx && ./sync-sta.sh"
uci set system.@button[-1].min=0
uci set system.@button[-1].max=1
uci commit system

# button configuration
uci add system button
uci set system.@button[-1].button=wps
uci set system.@button[-1].action=released
uci set system.@button[-1].handler="cd /root/xFengx && ./sync-ap.sh"
uci set system.@button[-1].min=2
uci set system.@button[-1].max=6
uci commit system

/root/xFengx/sync.sh

