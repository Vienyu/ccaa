#!/bin/bash
echo "$1"
if [ -e "/etc/sysconfig/iptables" ]
then
		iptables -I INPUT -p tcp --dport "$1" -j ACCEPT		
		service iptables save
		service iptables restart
elif [ -e "/etc/firewalld/zones/public.xml" ]
then
		firewall-cmd --zone=public --add-port="$1"/tcp --permanent
		firewall-cmd --reload
elif [ -e "/etc/ufw/before.rules" ]
then
		sudo ufw allow "$1"/tcp
fi
