FROM centos:7

ARG artifactory_host
RUN yum install -y which && yum clean all

COPY ca-salesforce.crt /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust enable && update-ca-trust extract
