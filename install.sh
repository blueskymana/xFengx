#!/bin/sh

/etc/init.d/firewall disable

cp ./rc.local /etc/
chmod +x /etc/rc.local
