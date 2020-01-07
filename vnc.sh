#!/bin/bash

if [ -e "/usr/bin/yum" ]
then
	sudo yum intall -y xfce4 slim tightvncserver xfonts-base xfonts-75dpi xfonts-100dpi >> ~/vnc-install.log
	sudo service slim start >> ~/vnc-install.log
	sudo useradd -m -p jfjfjf k
else
	sudo apt-get install -y lubuntu-core tightvncserver xfonts-base xfonts-75dpi xfonts-100dpi>> ~/vnc-install.log
	sudo service lightdm start >> ~/vnc-install.log
	sudo useradd -m -p "ffqmm9'" k
fi
sudo apt install -y xfonts-base xfonts-75dpi xfonts-100dpi
touch ~/.Xresources
cp config/xstartup ~/.vnc/xstartup
sudo chmod +x ~/.vnc/xstartup