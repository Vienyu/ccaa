#!/bin/bash

echo "Port 7788" >> /etc/ssh/sshd_config
service sshd restart

if [ -e "/etc/sysconfig/iptables" ]
then
	iptables -I INPUT -p tcp --dport 7788 -j ACCEPT
	service iptables save
	service iptables restart
elif [ -e "/etc/firewalld/zones/public.xml" ]
then		
	firewall-cmd --zone=public --add-port=7788/tcp --permanent
	firewall-cmd --reload
elif [ -e "/etc/ufw/before.rules" ]
then
	sudo ufw allow 7788/tcp
fi