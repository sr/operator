FROM docker.dev.pardot.com/base/centos:6

ARG artifactory_host
ARG dist=el6
ARG jemalloc_version=3.6.0-1.el6
ARG git_version=2.6.4-1
ARG percona_server_revision=39721841aef388886bb52a83d87ea97b58efe76e

RUN \
    yum install -y \
      epel-release \
  && \
    yum install -y \
      jemalloc-${jemalloc_version} \
  && \
    yum clean all

# Temporary installation method until
# <https://github.com/percona/percona-server/pull/1090> is released into a
# packaged version.
#
# https://www.percona.com/doc/percona-server/5.7/installation.html#compiling-percona-server-from-source
RUN \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/git-${git_version}.${dist}.x86_64.rpm" \
  && \
    yum install -y cmake libaio-devel ncurses-devel readline-devel bison bison-devel gcc gcc-c++ \
  && \
    cd /tmp \
  && \
    git clone https://github.com/percona/percona-server.git \
  && \
    cd percona-server \
  && \
    git checkout ${percona_server_revision} \
  && \
    git submodule update --init \
  && \
    cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_CONFIG=mysql_release -DFEATURE_SET=community -DWITH_EMBEDDED_SERVER=OFF -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/tmp/boost \
  && \
    make \
  && \
    make install \
  && \
    cd /tmp && rm -rf /tmp/percona-server /tmp/boost \
  && \
    yum clean all

COPY my.cnf /etc/my.cnf
RUN groupadd -r mysql -g 533 && \
  useradd -r -g mysql -d /var/lib/mysql -s /sbin/nologin -c "MySQL" -u 533 mysql
RUN mkdir -p /var/lib/mysql /var/log/mysql && \
  chown -R mysql:mysql /var/lib/mysql /var/log/mysql

ENV PATH $PATH:/usr/local/mysql/bin
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
