#!/usr/bin/env bash
set -euo pipefail
set -x

readonly ZFS_VERSION="0.6.5.9"

rpm -Uvh --replacepkgs http://download.zfsonlinux.org/epel/zfs-release.el7.noarch.rpm &&
  yum clean metadata &&
  yum install -q -y "zfs-${ZFS_VERSION}"

echo "zfs" > /etc/modules-load.d/zfs.conf

# Prevent cloud-init from messing with our ephemeral drives
sed -i'' -E '/- mounts/d' /etc/cloud/cloud.cfg

# Use ephemeral drives as a zpool for Docker and Bamboo's home
umount /dev/xvdb /dev/xvdc || true
sed -i'' -E '/xvd[bc]/d' /etc/fstab

# Make Bamboo aware of our arrangement with ZFS
cat <<-EOF >/opt/bamboo-elastic-agent/bin/setupEphemeralStorageStructure.sh
#!/usr/bin/env bash

if mountpoint -q /home; then
  echo "/home already mounted"
  exit 0
fi

systemctl start setup-ephemeral.service
rsync -avz --delete /home/ /mnt/home
mount --bind /mnt/home /home
EOF
chmod +x /opt/bamboo-elastic-agent/bin/setupEphemeralStorageStructure.sh

cat <<-EOF >/usr/local/bin/setup-ephemeral.sh
#!/usr/bin/env bash
set -euo pipefail

if ! /sbin/zpool status ephemeral &>/dev/null; then
  /sbin/zpool create -f ephemeral xvdb xvdc
  /sbin/zfs create -o mountpoint=/var/lib/docker ephemeral/docker
  /sbin/zfs create -o mountpoint=/mnt/home ephemeral/home
fi

for mount in /var/lib/docker /mnt/home; do
  if ! mountpoint -q "\$mount"; then
    find "\$mount" -mindepth 1 -delete
  fi
done
/sbin/zfs mount -a
EOF
chmod +x /usr/local/bin/setup-ephemeral.sh

cat <<-EOF >/etc/systemd/system/setup-ephemeral.service
[Unit]
Description=Creates an ZFS volume over the physical ephemeral disks
After=dev-xvdb.device dev-xvdc.device
Requires=dev-xvdb.device device-xvdc.device
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/setup-ephemeral.sh
EOF

rm -f /etc/systemd/system/var-lib-docker.mount
rm -f /etc/systemd/system/mnt-home.mount
