FROM docker.dev.pardot.com/base/centos:7

ARG maven_version=3.3.9
ARG jdk_version=8u102
ARG artifactory_host

ENV PATH="/usr/local/maven/bin:$PATH" \
  M2_HOME="/usr/local/maven" \
  JAVA_HOME=/usr/java/jdk1.8.0_102

RUN yum install -y epel-release && \
  yum install -y "https://${artifactory_host}/artifactory/pd-tarball/jdk/jdk-${jdk_version}-linux-x64.rpm" && \
  yum clean all

RUN curl -L "http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz" | tar -xzv -C /usr/local && \
  ln -sf "/usr/local/apache-maven-${maven_version}" /usr/local/maven
