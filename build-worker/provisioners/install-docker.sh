#!/usr/bin/env bash
set -euo pipefail
set -x

readonly DOCKER_VERSION="17.03.0.ce"
readonly COMPOSE_VERSION="1.11.2"

rm -f /etc/modules-load.d/overlay.conf

# shellcheck disable=SC2016
echo '[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg' > /etc/yum.repos.d/docker.repo

yum clean metadata
yum install -q -y "docker-engine-$DOCKER_VERSION"
mkdir -p /var/lib/docker

mkdir -p /etc/systemd/system/docker.service.d
echo '[Unit]
Requires=setup-ephemeral.service
After=setup-ephemeral.service
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --iptables=false --bip=10.0.42.1/16 --storage-driver=devicemapper --storage-opt=dm.thinpooldev=/dev/mapper/ephemeral-docker --storage-opt=dm.use_deferred_removal=true --storage-opt=dm.use_deferred_deletion=true --insecure-registry=docker-cache.aws.pardot.com
RestartSec=2
Restart=always
MountFlags=slave' > /etc/systemd/system/docker.service.d/docker.conf
systemctl daemon-reload
systemctl enable docker.service

curl -f -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" > /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

# bamboo can run docker commands
usermod -a -G docker bamboo

# sysctl settings for docker
echo 'net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1' > /etc/sysctl.d/80-docker.conf

# We run Docker with --iptables=false because of rampent race conditions in
# libnetwork and friends when starting multiple container stacks at the same
# time. Because our needs are simple on CI, though, we can get away with
# managing iptables on our own, so Docker doesn't have to futz with them and
# fail occasionally due to these race conditions. These rules are basic NAT
# rules so that containers can reach the external network (e.g., the Internet)
yum install -q -y iptables-services
iptables -t nat -F
# Docker BIP
iptables -t nat -A POSTROUTING -s 10.0.0.0/16 ! -d 10.0.0.0/16 -o eth0 -j MASQUERADE
# Possible Docker dynamic networks (172.16 - 172.26)
for octet in $(seq 16 26); do
  iptables -t nat -A POSTROUTING -s "172.${octet}.0.0/16" ! -d "172.${octet}.0.0/16" -o eth0 -j MASQUERADE
done
/usr/libexec/iptables/iptables.init save
systemctl enable iptables
systemctl start iptables
