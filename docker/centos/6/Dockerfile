FROM centos:6

ARG artifactory_host

COPY ca-salesforce.crt /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust enable && update-ca-trust extract
