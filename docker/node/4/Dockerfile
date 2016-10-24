FROM docker.dev.pardot.com/base/centos:6

ARG nodejs_version=4.6.1
ARG nodejs_checksum=cafa6e4bc66e3b8047f927c6cd3549398b9c11a94c73c9d0b9fc330e85e9697b
ARG npm_version=3
ARG git_version=2.6.4-1
ARG dist=el6
ARG artifactory_host

RUN yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/git-${git_version}.${dist}.x86_64.rpm"

RUN yum install -y xz && \
  curl -sf -o /tmp/node.tar.xz "https://nodejs.org/dist/v${nodejs_version}/node-v${nodejs_version}-linux-x64.tar.xz" && \
  sha256sum /tmp/node.tar.xz && \
  echo "${nodejs_checksum}  /tmp/node.tar.xz" | sha256sum -c - && \
  tar -xJ -C /usr --strip-components=1 -f /tmp/node.tar.xz && \
  rm -f /tmp/node.tar.xz && \
  npm install -g npm@${npm_version}