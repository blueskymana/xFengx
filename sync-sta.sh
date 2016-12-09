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

# sync network configuration
xfengx_uci_set adhoc wireless wifi-device[0] channel
xfengx_uci_set adhoc wireless wifi-device[0] hwmode
xfengx_uci_set adhoc wireless wifi-device[0] txpower
xfengx_uci_set adhoc wireless wifi-device[0] htmode

xfengx_uci_set adhoc wireless wifi-iface[0] mode
xfengx_uci_set adhoc wireless wifi-iface[0] ssid
xfengx_uci_set adhoc wireless wifi-iface[0] encryption
xfengx_uci_del wireless wifi-iface[0] network

#/etc/init.d/network reload

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

# get ssid key encryption.

#/etc/init.d/network restart
#iptables -t nat -A POSTROUTING -s 192.168.136.0/24 -o ath1 -j MASQUERADE
