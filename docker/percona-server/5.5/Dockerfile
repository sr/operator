FROM docker.dev.pardot.com/base/centos:6

ARG artifactory_host
ARG percona_major_version=55

RUN yum install -y https://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm && \
  yum install -y Percona-Server-client-${percona_major_version} Percona-Server-server-${percona_major_version} Percona-Server-devel-${percona_major_version}

COPY my.cnf /etc/my.cnf

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
