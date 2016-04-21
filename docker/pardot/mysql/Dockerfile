FROM docker.dev.pardot.com/base/centos:7

ARG percona_major_version=55
ARG artifactory_host

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

RUN yum install -y https://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm && \
  yum install -y Percona-Server-client-${percona_major_version} Percona-Server-server-${percona_major_version} Percona-Server-devel-${percona_major_version}

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

ADD my.cnf /etc/my.cnf

EXPOSE 3306
CMD ["mysqld"]
