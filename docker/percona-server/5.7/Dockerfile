FROM docker.dev.pardot.com/base/centos:6

ARG artifactory_host
ARG percona_major_version=57
ARG percona_version=5.7.14-7.1.el6
ARG jemalloc_version=3.6.0-1.el6

RUN \
    yum install -y \
      epel-release \
  && \
    yum install -y \
      jemalloc-${jemalloc_version} \
  && \
    yum install -y https://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm \
  && \
    yum install -y \
      Percona-Server-client-${percona_major_version}-${percona_version} \
      Percona-Server-server-${percona_major_version}-${percona_version} \
      Percona-Server-devel-${percona_major_version}-${percona_version} \
  && \
    yum clean all

COPY my.cnf /etc/my.cnf
RUN mkdir -p /var/lib/mysql /var/log/mysql && \
  chown -R mysql:mysql /var/lib/mysql /var/log/mysql

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
