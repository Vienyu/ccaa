#!/bin/bash

sudo apt-get install -y docker
apt install -y docker.io
docker pull v2ray/official
mkdir /etc/v2ray
cp config.json /etc/v2ray/

docker run -d --name v2ray -v /etc/v2ray:/etc/v2ray -p 80:80 v2ray/official  v2ray -config=/etc/v2ray/config.json
docker ps