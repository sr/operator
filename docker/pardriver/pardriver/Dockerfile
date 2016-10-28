FROM docker.dev.pardot.com/base/java:8u102-jdk

ARG artifactory_host

# The Maven cache and such is stored in /home/app
# The ParDriver application itself is stored in /app
RUN mkdir -p /app /home/app && \
  groupadd -r app -g 533 && \
  useradd -r -g app -d /home/app -s /bin/bash -u 533 app && \
  chown -R app: /app /home/app

USER app
WORKDIR /app

ADD pom.xml /app/pom.xml
RUN mvn dependency:resolve -Dartifactory_base=${artifactory_host}

# Fixes permissions on any ADDed files
USER root
RUN chown -R app: /app
USER app