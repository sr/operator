FROM docker.dev.pardot.com/base/java:8u102-jdk

ARG artifactory_host

RUN yum install -y epel-release && \
  yum install -y supervisor python-pip python-devel gcc which less rsync nmap && \
  pip install supervisor_checks && \
  yum clean all

COPY datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum clean metadata && \
  yum install -y dsc20 && \
  yum clean all
