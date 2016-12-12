#!/bin/sh 

uci_set() {
    VAL=$(uci -c $1 get ${3}.${5})
    if [ ! -z "$VAL" ];
    then
        uci -c $2 set ${4}.${5}=$VAL
        uci -c $2 commit ${6}
    fi
}

xfengx_uci_set() {
    uci_set /root/xFengx /etc/config ${1}.@${3} ${2}.@${3} ${4} ${2}
}

uci_del() {
    uci -c $1 delete ${2}.@${3}.${4}
    uci -c $1 commit ${2} 
}

xfengx_uci_del() {
    uci_del /etc/config ${1} ${2} ${3}
}

net_uci_set() {
    VAL=$(uci -c $1 get ${3}.${5}.${6})
    if [ ! -z "$VAL"  ];
    then
        uci -c ${2} set ${4}.${5}.${6}=$VAL
        uci -c ${2} commit ${4}
    fi
}

xfengx_net_uci_set() {
    net_uci_set /root/xFengx /etc/config ${1} ${2} ${3} ${4}
}

trigger_on() {
    echo default-on > /sys/devices/platform/leds-gpio/leds/ap147\:green\:wlan/trigger
}

trigger_blink() {
    echo timer > /sys/devices/platform/leds-gpio/leds/ap147\:green\:wlan/trigger
}


trigger_blink

# sync network configuration
xfengx_uci_set adhoc wireless wifi-device[0] channel
xfengx_uci_set adhoc wireless wifi-device[0] hwmode
xfengx_uci_set adhoc wireless wifi-device[0] txpower
xfengx_uci_set adhoc wireless wifi-device[0] htmode

xfengx_uci_set adhoc wireless wifi-iface[0] mode
xfengx_uci_set adhoc wireless wifi-iface[0] ssid
xfengx_uci_set adhoc wireless wifi-iface[0] encryption
xfengx_uci_del wireless wifi-iface[0] network

/etc/init.d/network reload
ifconfig ath0 192.168.10.2 netmask 255.255.255.0

sleep 5
UDP_ECHO=/root/xFengx/udpecho
netconfig=$($UDP_ECHO -s)

get_option() {
        echo $(echo $1 | awk -F ':' -v option="$2" '{ for (i=1; i<=NF; i++) { if($i==option) print $(i+1) } }')
}

ssid=$(get_option $netconfig ssid)
key=$(get_option $netconfig key)
encryption=$(get_option $netconfig encryption)

echo "$ssid $key $encryption"
uci set wireless.@wifi-iface[0].ssid="${ssid}2"
uci set wireless.@wifi-iface[0].key=$key
uci set wireless.@wifi-iface[0].encryption=$encryption
uci commit wireless


# wifi-device wifi0

xfengx_uci_set wireless-sta wireless wifi-device[0] channel  
xfengx_uci_set wireless-sta wireless wifi-device[0] hwmode
xfengx_uci_set wireless-sta wireless wifi-device[0] txpower
xfengx_uci_set wireless-sta wireless wifi-device[0] htmode

# wifi-iface wifi0

xfengx_uci_set wireless-sta wireless wifi-iface[0] network  
xfengx_uci_set wireless-sta wireless wifi-iface[0] mode     

# wifi-device wifi1

xfengx_uci_set wireless-sta wireless wifi-device[1] channel 
xfengx_uci_set wireless-sta wireless wifi-device[1] hwmode  
xfengx_uci_set wireless-sta wireless wifi-device[1] txpower 
xfengx_uci_set wireless-sta wireless wifi-device[1] htmode  

# wifi-iface wifi1

xfengx_uci_del wireless wifi-iface[1] network 
xfengx_uci_set wireless-sta wireless wifi-iface[1] mode    
xfengx_uci_set wireless-sta wireless wifi-iface[1] ssid    
xfengx_uci_set wireless-sta wireless wifi-iface[1] encryption  
xfengx_uci_set wireless-sta wireless wifi-iface[1] key     

# network

xfengx_net_uci_set network-sta network lan proto     
xfengx_net_uci_set network-sta network lan ipaddr
xfengx_net_uci_set network-sta network lan netmask
xfengx_net_uci_set network-sta network lan gateway
xfengx_net_uci_set network-sta network lan dns

/etc/init.d/network restart
udhcpc -i ath1 -T 15
iptables -t nat -A POSTROUTING -s 192.168.136.0/24 -o ath1 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward
/etc/init.d/dnsmasq restart
trigger_on
