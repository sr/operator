FROM docker.dev.pardot.com/base/node:6

ARG dist=el6
ARG phantomjs_version=2.1.1-1
ARG artifactory_host

RUN yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/phantomjs-${phantomjs_version}.${dist}.x86_64.rpm"

RUN mkdir -p /app && \
  groupadd -r app -g 533 && \
  useradd -r -g app -d /app -s /bin/bash -u 533 app && \
  chown -R app: /app

RUN npm install -g bower@1.7.9 && \
  npm install -g bower-art-resolver@2.0.7 && \
  npm install -g yarn@0.16.1

USER app
