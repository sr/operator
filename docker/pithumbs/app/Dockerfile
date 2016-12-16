FROM docker.dev.pardot.com/base/node:0.10.6

ARG artifactory_host

RUN yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/phantomjs-2.1.1-1.el6.x86_64.rpm" && \
  yum clean all

RUN npm install -g grunt-cli@0.1.13

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && \
  mkdir -p /app && \
  groupadd -r app -g 533 && \
  useradd -r -g app -d /app -s /bin/bash -u 533 app && \
  chown -R app: /app
