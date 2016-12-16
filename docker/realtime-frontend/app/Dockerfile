FROM docker.dev.pardot.com/base/node:0.10.6

ARG artifactory_host

RUN yum install -y gcc-c++ && \
  yum clean all

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && \
  mkdir -p /app && \
  groupadd -r app -g 533 && \
  useradd -r -g app -d /app -s /bin/bash -u 533 app && \
  chown -R app: /app
