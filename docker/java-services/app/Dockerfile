FROM docker.dev.pardot.com/base/centos:7

ARG maven_version=3.3.9
ARG jdk_version=7u79
ARG artifactory_host

ENV PATH="/usr/local/maven/bin:$PATH" \
  M2_HOME="/usr/local/maven"

RUN yum install -y which rsync && \
  yum install -y "https://${artifactory_host}/artifactory/pd-tarball/jdk/jdk-${jdk_version}-linux-x64.rpm"

RUN curl -L "http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz" | tar -xzv -C /usr/local && \
  ln -sf "/usr/local/apache-maven-${maven_version}" /usr/local/maven
