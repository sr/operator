FROM docker.dev.pardot.com/base/centos:7

ARG artifactory_host
ARG nodejs_version=4.5.0
ARG nodejs_sha256sum="c6ee1f4303353e3605ff70de180431417eb594fe08daf612e692216236750c55"

RUN yum install -y ant ruby xz bzip2 git && \
  cd /tmp && \
  curl -o node.tar.xz "https://nodejs.org/dist/v${nodejs_version}/node-v${nodejs_version}-linux-x64.tar.xz" && \
  echo "${nodejs_sha256sum}  node.tar.xz" | sha256sum -c - && \
  tar -C /usr/local --strip-components=1 -xvf node.tar.xz && \
  yum clean all

# Save public key information for remote Git servers
COPY known_hosts /etc/ssh/ssh_known_hosts
RUN chmod 0600 /etc/ssh/ssh_known_hosts
