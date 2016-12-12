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
    if [ ! -z "$VAL" ];
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

# wifi-device wifi0

xfengx_uci_set wireless wireless wifi-device[0] channel 
xfengx_uci_set wireless wireless wifi-device[0] hwmode  
xfengx_uci_set wireless wireless wifi-device[0] txpower 
xfengx_uci_set wireless wireless wifi-device[0] htmode  
xfengx_uci_set wireless wireless wifi-device[0] disabled

# wifi-iface wifi0

xfengx_uci_set wireless wireless wifi-iface[0] network  
xfengx_uci_set wireless wireless wifi-iface[0] mode     
xfengx_uci_set wireless wireless wifi-iface[0] ssid     
xfengx_uci_set wireless wireless wifi-iface[0] encryption  
xfengx_uci_set wireless wireless wifi-iface[0] key      

# wifi-device wifi1

xfengx_uci_set wireless wireless wifi-device[1] channel 
xfengx_uci_set wireless wireless wifi-device[1] hwmode  
xfengx_uci_set wireless wireless wifi-device[1] txpower 
xfengx_uci_set wireless wireless wifi-device[1] htmode  
xfengx_uci_set wireless wireless wifi-device[1] disabled

# wifi-iface wifi1

xfengx_uci_set wireless wireless wifi-iface[1] network 
xfengx_uci_set wireless wireless wifi-iface[1] mode    
xfengx_uci_set wireless wireless wifi-iface[1] ssid    
xfengx_uci_set wireless wireless wifi-iface[1] encryption  
xfengx_uci_set wireless wireless wifi-iface[1] key     

xfengx_net_uci_set network network lan proto     
xfengx_net_uci_set network network lan ipaddr
xfengx_net_uci_set network network lan netmask     
xfengx_net_uci_set network network lan gateway    
xfengx_net_uci_set network network lan dns    

reboot
