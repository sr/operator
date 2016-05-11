FROM docker.dev.pardot.com/base/centos:7

ARG percona_major_version=55
ARG nodejs_version=4.4.2
ARG bower_version=1.7.2
ARG parallel_version=20160322
ARG zookeeper_version=3.4.8
ARG phantomjs_version=2.1.1
ARG artifactory_host

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

RUN yum install -y epel-release && \
 yum install -y supervisor less which git openssh-clients redis bzip2 make unzip gcc java-1.7.0-openjdk

# Parallel
RUN cd /tmp && \
  curl -s "https://ftp.gnu.org/gnu/parallel/parallel-${parallel_version}.tar.bz2" | tar -xjv && \
  cd parallel-${parallel_version} && \
  ./configure && make && make install && \
  cd /tmp && \
  rm -rf parallel-${parallel_version}

# PHP
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum install -y \
    httpd mod_ssl \
    php70-php php70-php-mcrypt php70-php-mysql php70-php-bcmath php70-php-dom \
    php70-php-process php70-php-mbstring php70-php-zip php70-php-intl \
    php70-php-soap php70-php-xml php70-php-xmlrpc php70-php-gd php70-php-pdo \
    php70-php-opcache php70-php-tidy php70-php-pear php70-php-memcache \
    php70-php-cli php70-php-devel && \
  ln -sf /usr/bin/php70 /usr/bin/php

# PHP 7 compatible build of Protobuf
RUN cd /tmp && \
  git clone -b php7 https://github.com/pd-aray/php-protobuf && \
  cd php-protobuf && \
  /opt/remi/php70/root/bin/phpize && \
  ./configure --with-php-config=/opt/remi/php70/root/bin/php-config && \
  make install && \
  echo 'extension=protobuf.so' > /etc/opt/remi/php70/php.d/20-protobuf.ini && \
  cd /tmp && \
  rm -rf php-protobuf

# libzookeeper
RUN cd /tmp && \
  curl -s "http://apache.osuosl.org/zookeeper/zookeeper-${zookeeper_version}/zookeeper-${zookeeper_version}.tar.gz" | tar -xvz && \
  cd "zookeeper-${zookeeper_version}/src/c" && \
  ./configure && \
  make && \
  make install && \
  cd /tmp && \
  rm -rf "zookeeper-${zookeeper_version}"

# PHP 7 compatible build of Zookeeper
RUN cd /tmp && \
  git clone -b php7 https://github.com/jbboehr/php-zookeeper && \
  cd php-zookeeper && \
  /opt/remi/php70/root/bin/phpize && \
  ./configure --with-php-config=/opt/remi/php70/root/bin/php-config && \
  make && \
  make install && \
  echo 'extension=zookeeper.so' > /etc/opt/remi/php70/php.d/20-zookeeper.ini && \
  cd /tmp && \
  rm -rf php-zookeeper

# Percona Client
RUN yum install -y https://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm && \
  yum install -y Percona-Server-client-${percona_major_version} Percona-Server-devel-${percona_major_version}

# Phantom JS
RUN yum install -y fontconfig && \
  curl -L https://${artifactory_host}/artifactory/pd-tarball/phantomjs/phantomjs-${phantomjs_version}-linux-x86_64.tar.bz2 | tar -xjv -C /usr --strip-components=1

# Node.JS & Bower
RUN curl -s "https://nodejs.org/dist/v${nodejs_version}/node-v${nodejs_version}-linux-x64.tar.xz" | tar -xJ -C /usr --strip-components=1 && \
  npm install -g bower@${bower_version} && \
  npm install -g grunt-cli

# Save public key information for remote Git servers
RUN mkdir -p ~/.ssh && \
  chmod 0700 ~/.ssh && \
  ssh-keyscan git.dev.pardot.com > ~/.ssh/known_hosts && \
  ssh-keyscan github.com >> ~/.ssh/known_hosts && \
  chmod 0600 ~/.ssh/known_hosts

# GeoIP
RUN mkdir -p /var/www && \
  curl -L https://${artifactory_host}/artifactory/pd-tarball/bamboo-elastic-instance/geoip.tgz | tar -xzv -C /var/www

# Make room for demo fixtures
RUN mkdir -p /opt/pardot

ADD pardot.conf /etc/httpd/conf.d/pardot.conf
ADD apache.pem /etc/httpd/conf/apache.pem

ADD php.ini /etc/opt/remi/php70/php.d/90-pardot.ini
ADD supervisord.conf /etc/supervisord.conf
