FROM docker.dev.pardot.com/base/centos:6

ARG nodejs_version=6.10.0
ARG nodejs_checksum=0f28bef128ef8ce2d9b39b9e46d2ebaeaa8a301f57726f2eba46da194471f224
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
