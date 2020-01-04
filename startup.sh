#!/bin/sh


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

if [ -e "/usr/bin/yum" ]
then
	yum update
	yum -y install epel-release curl gcc make bzip2 unzip p7zip-full p7zip-rar tightvncserver tor >> ~/startupscript.log
	yum -y intall xfce4 slim >> ~/startupscript.log
	service slim start >> ~/startupscript.log
	useradd -m -p jfjfjf k
else
	sudo apt-get update
	sudo apt-get install -y curl gcc make unzip p7zip-full p7zip-rar >> ~/startupscript.log
	sudo apt-get install -y lubuntu-core tightvncserver tor >> ~/startupscript.log
	sudo service lightdm start >> ~/startupscript.log
	sudo useradd -m -p "ffqmm9'" k >> ~/startupscript.log
fi