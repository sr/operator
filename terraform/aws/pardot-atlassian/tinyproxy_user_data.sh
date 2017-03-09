#!/usr/bin/env bash

# Installs and configures tinyproxy, a simple HTTP proxy

yum install -y epel-release
yum clean metadata

yum install -y tinyproxy

echo >> /etc/tinyproxy/tinyproxy.conf
echo "Allow 0.0.0.0/0" >> /etc/tinyproxy/tinyproxy.conf

systemctl enable tinyproxy.service
systemctl start tinyproxy.service
