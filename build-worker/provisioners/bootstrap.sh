#!/usr/bin/env bash
set -euo pipefail
set -x

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"

# Disables SELinux
echo "SELINUX=permissive" > /etc/sysconfig/selinux
sudo setenforce 0

cp -p etc/hosts /etc/hosts
cp -p etc/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts
cp -p bin/* /usr/local/bin

yum upgrade -q -y

./install-modern-git.sh
./install-modern-kernel.sh
./install-bamboo-elastic-image.sh
./install-lvm2.sh
./install-docker.sh
./install-awscli.sh

# Make a directory where Bamboo can put an SSH_AUTH_SOCK for sharing into a container
mkdir -p /var/local/ssh-agent
chown bamboo:bamboo /var/local/ssh-agent

# Clean build directory every 10 min for directories that are 3 hours old
echo "*/10 * * * * root /usr/local/bin/clean-bamboo-build-dir.sh" > /etc/cron.d/build_cleanup

# Temporary hack required for the PPANT test suite
PDO_FIXTURE_DIR="/opt/pardot/demo-fixtures"
mkdir -p "$PDO_FIXTURE_DIR" && chown -R bamboo:bamboo "$PDO_FIXTURE_DIR"

# To workaround a Docker daemon networking bug, allow the Bamboo user to restart
# the Docker daemon as a cleanup procedure
echo "bamboo ALL=(root) NOPASSWD: /bin/systemctl restart docker.service" > /etc/sudoers.d/bamboo-docker

# Disables requiretty
sed -i'' -E 's/^(Defaults.*requiretty)/#\1/' /etc/sudoers

# Other various useful tools
yum install -q -y epel-release
yum clean metadata
yum install -q -y jq ruby rubygem-rake pigz vim-common iotop htop lsof \
  strace systemtap systemtap-sdt-devel perf

echo "Bootstrap finished successfully!"
