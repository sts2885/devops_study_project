#!/bin/bash
echo "This is DB" > index.html
nohup busybox httpd -f -p ${mysql_port} &

apt update
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update

apt install -y docker-ce docker-ce-cli containerd.io

systemctl start docker

docker run \
-itd \
-p ${node_exporter_port}:${node_exporter_port} \
--name node_exporter \
prom/node-exporter