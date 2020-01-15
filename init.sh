#!/bin/bash

if [ -e "/usr/bin/yum" ]
then
	sudo yum update
	sudo yum install -y epel-release curl gcc make p7zip-full p7zip-rar
else
	sudo apt update
	sudo apt install -y curl gcc make p7zip-full p7zip-rar
fi