FROM docker.dev.pardot.com/base/centos:6

ARG artifactory_host

RUN yum install -y squid && \
  echo "shutdown_lifetime 1 second" >> /etc/squid/squid.conf

USER squid
EXPOSE 3128
CMD ["squid", "-N"]
