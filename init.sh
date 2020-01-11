#!/bin/bash

if [ -e "/usr/bin/yum" ]
then
	sudo yum update >> ~/init.log
	sudo yum install -y epel-release curl gcc make p7zip-full p7zip-rar >> ~/init.log
else
	sudo apt update >> ~/init.log
	sudo apt install -y curl gcc make p7zip-full p7zip-rar >> ~/init.log
fi