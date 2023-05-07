#!/bin/bash
apt update
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update

apt install -y docker-ce docker-ce-cli containerd.io

systemctl start docker
echo """
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 0.0.0.0:9090

""" | tee /home/ubuntu/prometheus.yml


docker run \
-itd \
-p 9090:9090 \
--name prometheus \
-v /home/ubuntu/prometheus.yml:/etc/prometheus/prometheus.yml \
prom/prometheus


docker run -itd \
--name grafana \
-p 3000:3000 \
grafana/grafana
