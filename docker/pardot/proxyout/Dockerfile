FROM docker.dev.pardot.com/base/centos:6

ARG artifactory_host

RUN yum install -y squid

USER squid
EXPOSE 3128
CMD ["squid", "-N"]
