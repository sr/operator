FROM docker.dev.pardot.com/base/centos:6

ARG dist=el6
ARG percona_major_version=55
ARG nodejs_version=4.4.2
ARG bower_version=1.7.2
ARG parallel_version=20160322
ARG phantomjs_version=2.1.1-1
ARG libzookeeper_version=3.4.6-1.pardot
ARG git_version=2.7.4-1
# https://git.dev.pardot.com/Pardot/chef/blob/master/cookbooks/pardot_php70/attributes/default.rb
ARG php_version=7.0.8-1
ARG php_packages="php-json php-common php-cli php-devel php php-mcrypt php-mbstring php-pdo php-xml php-xmlrpc php-imap php-gd php-tidy php-bcmath php-intl php-opcache php-mysqlnd php-process"
ARG artifactory_host

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && \
  ln -sf /var/lib/rmux/rmux-master.sock /tmp/rmux-master.sock && \
  ln -sf /var/lib/rmux/rmux-slave.sock /tmp/rmux-slave.sock && \
  ln -sf /var/lib/rmux/rmux-rules-master.sock /tmp/rmux-rules-master.sock && \
  ln -sf /var/lib/rmux/rmux-rules-slave.sock /tmp/rmux-rules-slave.sock

RUN yum install -y epel-release && \
  yum install -y \
    font-config supervisor less which openssh-clients redis bzip2 make \
    unzip xz gcc file libicu openssl nc yum-versionlock && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/jre-7u80-linux-x64.rpm" && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/libzookeeper-devel-${libzookeeper_version}.${dist}.x86_64.rpm" && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/git-${git_version}.${dist}.x86_64.rpm" && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-yum/phantomjs-${phantomjs_version}.${dist}.x86_64.rpm" && \
  yum clean all

# Parallel
RUN cd /tmp && \
  curl -s "https://ftp.gnu.org/gnu/parallel/parallel-${parallel_version}.tar.bz2" | tar -xjv && \
  cd parallel-${parallel_version} && \
  ./configure && make && make install && \
  cd /tmp && \
  rm -rf parallel-${parallel_version}

# PHP
COPY remi-php70.repo remi-safe.repo /etc/yum.repos.d/
RUN yum install -y httpd mod_ssl && \
  sed -i'' "s/artifactory\.dev\.pardot\.com/${artifactory_host}/" /etc/yum.repos.d/remi-php70.repo && \
  for package in ${php_packages}; do \
    yum --enablerepo=remi-php70 install -y "${package}-${php_version}.${dist}.remi"; \
    yum versionlock "${package}"; \
  done && \
  yum --enablerepo=remi-php70 install -y "php-pear-1.10.1-4.${dist}.remi" && \
  yum --enablerepo=remi-php70 install -y "php-pecl-memcache-3.0.9-0.4.20160311git4991c2f.${dist}.remi.7.0" && \
  yum --enablerepo=remi-php70 install -y "php-pecl-igbinary-1.2.2-0.1.20151217git2b7c703.${dist}.remi.7.0" && \
  yum --enablerepo=remi-php70 install -y "php-pecl-zip-1.13.3-1.${dist}.remi.7.0" && \
  yum --enablerepo=remi-php70 install -y "php-pecl-xdebug-2.4.0-1.${dist}.remi.7.0" && \
  rpm -Uvh "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/php-soap-7.0.8-2.pardot.${dist}.x86_64.rpm" && \
  rpm -Uvh "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/php-zookeeper-7.0.8-1.pardot.${dist}.x86_64.rpm" && \
  rpm -Uvh "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/php-protobuf-7.0.8-1.pardot.${dist}.x86_64.rpm" && \
  rpm -Uvh "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/php-pecl-encryption-gnupg-7.0.8-1.pardot.${dist}.x86_64.rpm" && \
  pear install --onlyreqdeps "Crypt_HMAC" && \
  pear install --onlyreqdeps "Net_Curl" && \
  rm -f /etc/php.d/*xdebug.ini && \
  yum clean all

# Percona Client
RUN yum install -y https://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm && \
  yum install -y Percona-Server-client-${percona_major_version} Percona-Server-devel-${percona_major_version} && \
  yum clean all

# Node.JS & Bower
RUN curl -s "https://nodejs.org/dist/v${nodejs_version}/node-v${nodejs_version}-linux-x64.tar.xz" | tar -xJ -C /usr --strip-components=1 && \
  npm install -g bower@${bower_version} && \
  npm install -g grunt-cli

# Save public key information for remote Git servers
RUN mkdir -p /root/.ssh
COPY known_hosts /root/.ssh/known_hosts
RUN chmod 0700 /root/.ssh && chmod 0600 /root/.ssh/known_hosts

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
