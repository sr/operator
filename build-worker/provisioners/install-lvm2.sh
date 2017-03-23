#!/usr/bin/env bash
set -euo pipefail
set -x

# Prevent cloud-init from messing with our ephemeral drives
if [ -e /etc/cloud/cloud.cfg ]; then
  sed -i'' -E '/- mounts/d' /etc/cloud/cloud.cfg
fi

# Use ephemeral drives as a LVM virtual group for Docker and Bamboo's home
umount /dev/xvdb /dev/xvdc || true
sed -i'' -E '/xvd[bc]/d' /etc/fstab

yum install -q -y lvm2

# Make Bamboo aware of our arrangement with LVM/devicemapper
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

cat <<-EOF >/etc/lvm/profile/ephemeral-thinpool.profile
activation {
  thin_pool_autoextend_threshold = 80
  thin_pool_autoextend_percent = 10
}

allocation {
  thin_pool_chunk_size_policy = "performance"
  thin_pool_zero = 0
}
EOF

cat <<-EOF >/usr/local/bin/setup-ephemeral.sh
#!/usr/bin/env bash
set -euo pipefail

if ! pvs /dev/xvd[bc] &>/dev/null; then
  dd if=/dev/zero of=/dev/xvdb bs=1M count=10
  dd if=/dev/zero of=/dev/xvdc bs=1M count=10

  pvcreate /dev/xvd[bc]
  vgcreate ephemeral /dev/xvd[bc]

  lvcreate --stripes 2 --stripesize 256 \
    --zero n \
    -L 10G \
    --name home \
    ephemeral

  lvcreate --stripes 2 --stripesize 256 \
    --zero n \
    --type thin-pool \
    --thinpool ephemeral/docker \
    -l 95%FREE
  lvchange --metadataprofile ephemeral-thinpool ephemeral/docker
fi

lvs -o+seg_monitor

for mount in /var/lib/docker /mnt/home; do
  if [ -d "\$mount" ] && ! mountpoint -q "\$mount"; then
    find "\$mount" -mindepth 1 -delete
  fi
done

if ! mountpoint -q "/mnt/home"; then
  mkfs.xfs -f /dev/mapper/ephemeral-home
  mkdir -p /mnt/home
  mount /dev/mapper/ephemeral-home /mnt/home
fi
EOF
chmod +x /usr/local/bin/setup-ephemeral.sh

cat <<-EOF >/etc/systemd/system/setup-ephemeral.service
[Unit]
Description=Creates an LVM volume over the physical ephemeral disks
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/setup-ephemeral.sh
EOF
