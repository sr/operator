FROM docker.dev.pardot.com/base/centos:6

ARG nodejs_version=0.10.6
ARG nodejs_checksum=cc7ccfce24ae0ebb0c50661ef8d98b5db07fc1cd4a222c5d1ae232260d5834ca
ARG git_version=2.6.4-1
ARG dist=el6
ARG artifactory_host

RUN yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/git-${git_version}.${dist}.x86_64.rpm"

RUN yum install -y xz && \
  curl -sf -o /tmp/node.tar.xz "https://nodejs.org/download/release/v${nodejs_version}/node-v${nodejs_version}-linux-x64.tar.gz" && \
  sha256sum /tmp/node.tar.xz && \
  echo "${nodejs_checksum}  /tmp/node.tar.xz" | sha256sum -c - && \
  tar -xz -C /usr --strip-components=1 -f /tmp/node.tar.xz && \
  rm -f /tmp/node.tar.xz