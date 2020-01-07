#!/bin/bash
#####	一键安装Caddy + Aria2 + AriaNg		#####
#####	作者：xiaoz.me						#####
#####	更新时间：2019-05-15				#####

#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

#安装之前的准备
function setout(){
	echo 'setout()'
	if [ -e "/usr/bin/yum" ]
	then
		yum -y install epel-release 
		yum -y install curl gcc make bzip2 p7zip unrar
		yum -y install gcc+
	else
		#更新软件，否则可能make命令无法安装
		sudo apt-get update
		sudo apt-get install -y curl make p7zip unzip
		sudo apt install p7zip-full
		sudo apt install unrar
	fi
	#echo "Port 7788" >> /etc/ssh/sshd_config
	#service sshd restart
	echo 'setout() finished!'
}
#安装Aria2
function install_aria2(){
	echo 'install_aria2()'
	sudo mkdir -p /etc/ccaa/
	sudo touch /etc/ccaa/aria2.session
	sudo touch /etc/ccaa/aria2.log
	sudo cp aria2.conf /etc/ccaa/
	sudo cp upbt.sh /etc/ccaa/
	sudo cp aria2_auto_move.sh /etc/ccaa/
	sudo cp aria2_on_download_complete.sh /etc/ccaa/

	sudo chmod +x /etc/ccaa/upbt.sh
	sudo chmod +x /etc/ccaa/aria2_auto_move.sh
	sudo chmod +x /etc/ccaa/aria2_on_download_complete.sh


		echo '-------------------------------------------------------------'
		read -p "设置 Aria2 下载路径（请填写绝对地址，默认/data/ccaaDowning）:" downingpath
		read -p "设置存储路径（请填写绝对地址，默认/data/ccaaDown）:" downpath
		read -p "Aria2 RPC 密钥:(字母或数字组合，不要含有特殊字符，默认canbya):" secret
		echo '-------------------------------------------------------------'

	#如果 Aria2 下载路径为空，设置默认下载路径
	if [ -z "${downingpath}" ]
	then
		downingpath='/data/ccaaDowning'
	fi
	#如果下载路径为空，设置默认下载路径
	if [ -z "${downpath}" ]
	then
		downpath='/data/ccaaDown'
	fi
	#如果RPC 密钥为空，设置默认 RPC 密钥
	if [ -z "${secret}" ]
	then
		secret='canbya'
	fi

	sudo mkdir -p ${downingpath}
	sudo mkdir -p ${downpath}
	
	sudo sed -i "s%dir=%dir=${downingpath}%g" /etc/ccaa/aria2.conf
	sudo sed -i "s/rpc-secret=/rpc-secret=${secret}/g" /etc/ccaa/aria2.conf
	sudo sed -i "s%COMDIR=%COMDIR=${downpath}%g" /etc/ccaa/aria2_on_download_complete.sh

	#yum -y update
	#安装aria2静态编译版本，来源于https://github.com/q3aql/aria2-static-builds/
	wget -c http://soft.xiaoz.org/linux/aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2
	tar jxvf aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2
	cd aria2-1.34.0-linux-gnu-64bit-build1
	sudo make install
	cd ..
	
	#更新tracker
	bash /etc/ccaa/upbt.sh
	#启动服务
	#sudo nohup aria2c --conf-path=/etc/ccaa/aria2.conf > /etc/ccaa/aria2.log 2>&1 &
	sudo nohup aria2c --conf-path=/etc/ccaa/aria2.conf

	echo 'install_aria2() Finished!'
}
#安装caddy
function install_caddy(){
	echo 'install_caddy()'
	pwd
	sudo mkdir -p /etc/ccaa/
	sudo touch /etc/ccaa/caddy.log
	sudo cp caddy.conf /etc/ccaa/
	
	#if["$quiet" == 'n']
	#then
		echo '-------------------------------------------------------------'
		read -p "设置Caddy用户名（默认k）:" caddyuser
		read -p "设置Caddy密码（默认canbya）:" caddypass
		echo '-------------------------------------------------------------'
	#fi
	#如果 Caddy 用户名为空，设置默认用户名
	if [ -z "${caddyuser}" ]
	then
		caddyuser='k'
	fi
	#如果 Caddy 密码为空，设置默认密码
	if [ -z "${caddypass}" ]
	then
		caddypass='canbya'
	fi

	#执行替换操作	
	sudo sed -i "s/username/${caddyuser}/g" /etc/ccaa/caddy.conf
	sudo sed -i "s/password/${caddypass}/g" /etc/ccaa/caddy.conf
	#sed -i "s%/home%${downpath}%g" /etc/ccaa/caddy.conf
	sudo sed -i "s%/admin%/admin ${downpath}%g" /etc/ccaa/caddy.conf

	#一键安装https://caddyserver.com/download/linux/amd64?plugins=http.filemanager&license=personal&telemetry=off
	#curl https://getcaddy.com | bash -s personal http.filemanager
	#安装caddy
	wget http://soft.xiaoz.org/linux/caddy_v0.11.0_linux_amd64_custom_personal.tar.gz -O caddy.tar.gz
	tar -zxvf caddy.tar.gz
	sudo mv caddy /usr/sbin/
	sudo chmod +x /usr/sbin/caddy
	#添加服务
	#mv init/linux-systemd/caddy.service /lib/systemd/system
	#chmod +x /lib/systemd/system/caddy.service
	#开机启动
	#systemctl enable caddy.service
	
	#安装AriaNg
	wget http://soft.xiaoz.org/website/AriaNg.zip
	unzip AriaNg.zip
	sudo cp -a AriaNg /etc/ccaa

	#启动服务
	#sudo nohup caddy -conf="/etc/ccaa/caddy.conf" > /etc/ccaa/caddy.log 2>&1 &
	sudo nohup caddy -conf="/etc/ccaa/caddy.conf"
	
	echo 'install_caddy() Finished!'
}

#处理配置文件
function dealconf(){
	echo 'dealconf()!'
	pwd
	#创建目录和文件
	sudo cp ccaa /usr/sbin
	sudo chmod +x /usr/sbin/ccaa
	sudo cp oport.sh /usr/sbin
	sudo chmod +x /usr/sbin/oport.sh

	sudo chmod +x bin/*
	sudo cp bin/* /usr/sbin
	echo 'dealconf() Finished!'
}
#自动放行端口
function chk_firewall(){
	echo 'chk_firewall()'
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 6080 -j ACCEPT
		iptables -I INPUT -p tcp --dport 6800 -j ACCEPT
		iptables -I INPUT -p tcp --dport 6998 -j ACCEPT
		iptables -I INPUT -p tcp --dport 51413 -j ACCEPT
		#iptables -I INPUT -p tcp --dport 7788 -j ACCEPT
		service iptables save
		service iptables restart
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --add-port=6080/tcp --permanent
		firewall-cmd --zone=public --add-port=6800/tcp --permanent
		firewall-cmd --zone=public --add-port=6998/tcp --permanent
		firewall-cmd --zone=public --add-port=51413/tcp --permanent
		#firewall-cmd --zone=public --add-port=7788/tcp --permanent
		firewall-cmd --reload
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw allow 6080/tcp
		sudo ufw allow 6800/tcp
		sudo ufw allow 6998/tcp
		sudo ufw allow 51413/tcp
		#sudo ufw allow 7788/tcp
	fi
	echo 'chk_firewall() finished!'
}
#删除端口
function del_post() {
	echo 'del_post() finished!'

	if [ -e "/etc/sysconfig/iptables" ]
	then
		sed -i '/^.*6080.*/'d /etc/sysconfig/iptables
		sed -i '/^.*6800.*/'d /etc/sysconfig/iptables
		sed -i '/^.*6998.*/'d /etc/sysconfig/iptables
		sed -i '/^.*51413.*/'d /etc/sysconfig/iptables
		service iptables save
		service iptables restart
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --remove-port=6080/tcp --permanent
		firewall-cmd --zone=public --remove-port=6800/tcp --permanent
		firewall-cmd --zone=public --remove-port=6998/tcp --permanent
		firewall-cmd --zone=public --remove-port=51413/tcp --permanent
		firewall-cmd --reload
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw delete 6080/tcp
		sudo ufw delete 6800/tcp
		sudo ufw delete 6998/tcp
		sudo ufw delete 51413/tcp
	fi
	
	echo 'del_post() finished!'
}
#设置账号密码
function setting(){
	echo 'setting()'

	#获取ip
	osip=$(curl -4s https://api.ip.sb/ip)

	echo '-------------------------------------------------------------'
	echo "大功告成，请访问: http://${osip}:6080/"
	echo '用户名:' ${caddyuser}
	echo '密码:' ${caddypass}
	echo 'Aria2 RPC 密钥:' ${secret}
	echo '帮助文档: https://dwz.ovh/ccaa （必看）' 
	echo '-------------------------------------------------------------'
}
#清理工作
function cleanup(){
	echo 'cleanup()'
	sudo rm -rf *.zip
	sudo rm -rf *.gz
	sudo rm -rf *.txt
	sudo rm -rf aria2-1.34*
	#rm -rf *.conf
	sudo rm -rf init
}

#卸载
function uninstall(){
	#停止所有服务
	sudo kill -9 $(pgrep 'aria2c')
	sudo kill -9 $(pgrep 'caddy')

	#删除服务
	#systemctl disable caddy.service
	#rm -rf /lib/systemd/system/caddy.service
	#删除文件
	sudo rm -rf /etc/ccaa
	sudo rm -rf /usr/sbin/caddy
	sudo rm -rf /usr/sbin/ccaa
	sudo rm -rf /usr/bin/aria2c
	sudo rm -rf aria2-1.*
	sudo rm -rf AriaNg*
	

	sudo rm -rf /usr/share/man/man1/aria2c.1
	sudo rm -rf /etc/ssl/certs/ca-certificates.crt
	#删除端口
	del_post
	echo "------------------------------------------------"
	echo '卸载完成！'
	echo "------------------------------------------------"
}

#选择安装方式
echo "------------------------------------------------"
echo "Linux + Caddy + Aria2 + AriaNg一键安装脚本(CCAA)"
echo "1) 安装 Aria2"
echo "2) 安装 CCAA"
echo "3) 卸载 CCAA"
echo "4) 更新 bt-tracker"
echo "q) 退出！"
read -p ":" istype
case $istype in
	1) 
    	setout
    	install_aria2 && \
    	dealconf && \
    	chk_firewall && \
    	setting && \
    	cleanup
    ;;
    2) 
    	setout
    	install_aria2 && \
    	install_caddy && \
    	dealconf && \
    	chk_firewall && \
    	setting && \
    	cleanup
    ;;
    3) 
    	uninstall
    ;;
    4) 
    	bash ./upbt.sh
    ;;
    q) 
    	exit
    ;;
    *) echo '参数错误！'
esac