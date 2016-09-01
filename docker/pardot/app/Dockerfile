FROM docker.dev.pardot.com/base/php:7.0.8

ARG dist=el6
ARG percona_major_version=55
ARG nodejs_version=4.4.2
ARG bower_version=1.7.2
ARG parallel_version=20160322
ARG phantomjs_version=2.1.1-1
ARG artifactory_host

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && \
  ln -sf /var/lib/rmux/rmux-master.sock /tmp/rmux-master.sock && \
  ln -sf /var/lib/rmux/rmux-slave.sock /tmp/rmux-slave.sock && \
  ln -sf /var/lib/rmux/rmux-rules-master.sock /tmp/rmux-rules-master.sock && \
  ln -sf /var/lib/rmux/rmux-rules-slave.sock /tmp/rmux-rules-slave.sock

RUN yum install -y epel-release && \
  yum install -y font-config supervisor redis bzip2 unzip xz make gcc file libicu openssl nc && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/jre-7u80-linux-x64.rpm" && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/phantomjs-${phantomjs_version}.${dist}.x86_64.rpm" && \
  yum clean all

# Parallel
RUN cd /tmp && \
  curl -s "https://ftp.gnu.org/gnu/parallel/parallel-${parallel_version}.tar.bz2" | tar -xjv && \
  cd parallel-${parallel_version} && \
  ./configure && make && make install && \
  cd /tmp && \
  rm -rf parallel-${parallel_version}

# Percona Client
RUN yum install -y https://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm && \
  yum install -y Percona-Server-client-${percona_major_version} Percona-Server-devel-${percona_major_version} && \
  yum clean all

# Node.JS & Bower
RUN curl -s "https://nodejs.org/dist/v${nodejs_version}/node-v${nodejs_version}-linux-x64.tar.xz" | tar -xJ -C /usr --strip-components=1 && \
  npm install -g bower@${bower_version} && \
  npm install -g grunt-cli

# GeoIP
RUN mkdir -p /var/www && \
  curl -L https://${artifactory_host}/artifactory/pd-tarball/bamboo-elastic-instance/geoip.tgz | tar -xzv -C /var/www

# Make room for demo fixtures
RUN mkdir -p /opt/pardot

ADD pardot.conf /etc/httpd/conf.d/pardot.conf
ADD apache.pem /etc/httpd/conf/apache.pem

ADD php.ini /etc/php.d/90-pardot.ini
ADD supervisord.conf /etc/supervisord.conf

RUN mkdir -p /app
WORKDIR /app

ENTRYPOINT ["/app/docker/entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
