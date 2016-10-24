FROM docker.dev.pardot.com/base/node:4

ARG artifactory_host

RUN mkdir -p /app && \
  groupadd -r app -g 533 && \
  useradd -r -g app -d /app -s /bin/bash -u 533 app && \
  chown -R app: /app

RUN npm install -g bower@1.7.9 && \
  npm install -g yarn@0.16.1

USER app