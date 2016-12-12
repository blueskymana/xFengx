#!/bin/sh 

uci_set() {
    VAL=$(uci -c $1 get ${3}.${5})
    if [ ! -z "$VAL" ];
    then
        uci -c $2 set ${4}.${5}=$VAL
        uci -c $2 commit ${6}
    fi
}

uci_get() {
    echo $(uci -c ${1} get ${2}.${3})
}

xfeng_uci_get() {
    echo $(uci_get /etc/config ${1}.@${2} ${3})
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

# save network info

ssid=$(xfeng_uci_get wireless wifi-iface[0] ssid)
key=$(xfeng_uci_get wireless wifi-iface[0] key)
encryption=$(xfeng_uci_get wireless wifi-iface[0] encryption)

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
ifconfig ath0 192.168.10.1 netmask 255.255.255.0

sleep 5
# transfer tools
UDP_ECHO=/root/xFengx/udpecho

bcast=192.168.10.255

# sync data
syncdata="ssid:${ssid}:key:${key}:encryption:${encryption}"
echo $syncdata

# transfer data

for i in {1..6}
do
    $UDP_ECHO $bcast $syncdata 
    echo $syncdata
    sleep 1
done

uci set wireless.@wifi-iface[0].ssid=$ssid
uci set wireless.@wifi-iface[0].key=$key
uci set wireless.@wifi-iface[0].encryption=$encryption
uci commit wireless

# wifi-device wifi0

xfengx_uci_set wireless-ap wireless wifi-device[0] channel
xfengx_uci_set wireless-ap wireless wifi-device[0] hwmode
xfengx_uci_set wireless-ap wireless wifi-device[0] txpower
xfengx_uci_set wireless-ap wireless wifi-device[0] htmode

# wifi-iface wifi0

xfengx_uci_set wireless-ap wireless wifi-iface[0] network  
xfengx_uci_set wireless-ap wireless wifi-iface[0] mode    

# wifi-device wifi1

xfengx_uci_set wireless-ap wireless wifi-device[1] channel 
xfengx_uci_set wireless-ap wireless wifi-device[1] hwmode  
xfengx_uci_set wireless-ap wireless wifi-device[1] txpower 
xfengx_uci_set wireless-ap wireless wifi-device[1] htmode  

# wifi-iface wifi1

xfengx_uci_set wireless-ap wireless wifi-iface[1] network
xfengx_uci_set wireless-ap wireless wifi-iface[1] mode    
xfengx_uci_set wireless-ap wireless wifi-iface[1] ssid   
xfengx_uci_set wireless-ap wireless wifi-iface[1] encryption  
xfengx_uci_set wireless-ap wireless wifi-iface[1] key     

# network 

xfengx_net_uci_set network-ap network lan proto     
xfengx_net_uci_set network-ap network lan ipaddr    
xfengx_net_uci_set network-ap network lan netmask    
xfengx_net_uci_set network-ap network lan gateway   
xfengx_net_uci_set network-ap network lan dns   

#send sync data

/etc/init.d/network restart
trigger_on

