FROM docker.dev.pardot.com/base/node:6

ARG dist=el6
ARG phantomjs_version=2.1.1-1
ARG yarn_version=0.21.3
ARG yarn_checksum=0946a4d1abc106c131b700cc31e5c3aa5f2205eb3bb9d17411f8115354a97d5d
ARG artifactory_host

RUN yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/phantomjs-${phantomjs_version}.${dist}.x86_64.rpm"

RUN cd /opt && \
  mkdir yarn && \
  curl -Lo yarn.tar.gz "https://github.com/yarnpkg/yarn/releases/download/v${yarn_version}/yarn-v${yarn_version}.tar.gz" && \
  echo "${yarn_checksum}  yarn.tar.gz" | sha256sum -c - && \
  tar --strip-components=1 -C /opt/yarn -xvf yarn.tar.gz && \
  rm -f yarn.tar.gz && \
  ln -sf /opt/yarn/bin/yarn{,pkg} /usr/bin

RUN mkdir -p /app && \
  groupadd -r app -g 533 && \
  useradd -r -g app -d /app -s /bin/bash -u 533 app && \
  chown -R app: /app

RUN npm install -g bower@1.7.9 && \
  npm install -g bower-art-resolver@2.0.7

USER app
