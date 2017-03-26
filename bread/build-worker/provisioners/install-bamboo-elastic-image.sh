#!/usr/bin/env bash
set -euo pipefail
set -x

# https://confluence.atlassian.com/bamboo/creating-a-custom-elastic-image-linux-296093037.html

# Periodically bump this to the latest from:
# https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/bamboo/atlassian-bamboo-elastic-image/
readonly IMAGE_VER=6.1

yum clean metadata
yum install -q -y java-1.8.0

rm -rf /opt/ec2-api-tools
rm -rf ec2-api-tools*
yum install -q -y wget unzip
wget https://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip
mv ec2-api-tools-* /opt/ec2-api-tools

id bamboo || useradd -m bamboo

rm -rf /opt/bamboo-elastic-agent
rm -rf atlassian-bamboo-elastic-image*
wget https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/bamboo/atlassian-bamboo-elastic-image/${IMAGE_VER}/atlassian-bamboo-elastic-image-${IMAGE_VER}.zip
sudo mkdir -p /opt/bamboo-elastic-agent
sudo unzip -o atlassian-bamboo-elastic-image-${IMAGE_VER}.zip -d /opt/bamboo-elastic-agent
sudo chown -R bamboo /opt/bamboo-elastic-agent
sudo chmod -R u+r+w /opt/bamboo-elastic-agent

chown -R bamboo:bamboo /home/bamboo/

# shellcheck disable=SC2016
echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0
export EC2_HOME=/opt/ec2-api-tools
export EC2_PRIVATE_KEY=/root/pk.pem
export EC2_CERT=/root/cert.pem
export PATH=/opt/bamboo-elastic-agent/bin:$EC2_HOME/bin:$JAVA_HOME/bin:$M2_HOME/bin:$MAVEN_HOME/bin:$ANT_HOME/bin:$PATH' > /etc/profile.d/bamboo.sh
chmod 0755 /etc/profile.d/bamboo.sh

if ! grep -q '^\. /opt/bamboo-elastic-agent/etc/rc.local' /etc/rc.local; then
  echo '. /opt/bamboo-elastic-agent/etc/rc.local' >> /etc/rc.local
fi
chmod 0755 /etc/rc.local

cp -f /opt/bamboo-elastic-agent/etc/motd /etc/motd

rm -f /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub
rm -f /root/firstlogin
touch /root/firstrun
