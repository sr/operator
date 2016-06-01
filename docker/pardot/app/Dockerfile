FROM docker.dev.pardot.com/base/centos:6

ARG percona_major_version=55
ARG nodejs_version=4.4.2
ARG bower_version=1.7.2
ARG parallel_version=20160322
ARG phantomjs_version=2.0-1
ARG libzookeeper_version=3.4.6-1
ARG php_protobuf_revision=a6c74a9f0324c56809aa05eaa321267d60055017
ARG artifactory_host

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

RUN yum install -y epel-release && \
  yum install -y \
    font-config supervisor less which git openssh-clients redis bzip2 make \
    unzip xz gcc file libicu openssl java-1.7.0-openjdk && \
  rpm -Uvh "https://${artifactory_host}/artifactory/pd-yum/libzookeeper-devel-${libzookeeper_version}.el6.x86_64.rpm" && \
  rpm -Uvh "https://${artifactory_host}/artifactory/pd-yum/phantomjs-${phantomjs_version}.el6.x86_64.rpm" && \
  yum clean all

# Parallel
RUN cd /tmp && \
  curl -s "https://ftp.gnu.org/gnu/parallel/parallel-${parallel_version}.tar.bz2" | tar -xjv && \
  cd parallel-${parallel_version} && \
  ./configure && make && make install && \
  cd /tmp && \
  rm -rf parallel-${parallel_version}

# PHP
RUN yum install -y httpd mod_ssl && \
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && \
  yum --enablerepo=remi-php55 install -y \
    php php-mcrypt php-mysql php-bcmath php-dom php-process php-mbstring \
    php-zip php-intl php-soap php-xml php-xmlrpc php-gd php-pdo php-opcache \
    php-tidy php-pear php-memcache php-cli php-devel && \
  yum clean all

# PHP 5.5 compatible build of Protobuf
RUN cd /tmp && \
  git clone https://github.com/pd-aray/php-protobuf && \
  cd php-protobuf && \
  git checkout ${php_protobuf_revision} && \
  phpize && \
  ./configure && \
  make install && \
  echo 'extension=protobuf.so' > /etc/php.d/20-protobuf.ini && \
  cd /tmp && \
  rm -rf php-protobuf

# PECL extensions
RUN yes '' | pecl install zookeeper-beta && \
  echo 'extension=zookeeper.so' > /etc/php.d/20-zookeeper.ini

# Percona Client
RUN yum install -y https://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm && \
  yum install -y Percona-Server-client-${percona_major_version} Percona-Server-devel-${percona_major_version} && \
  yum clean all

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

ADD php.ini /etc/php.d/90-pardot.ini
ADD supervisord.conf /etc/supervisord.conf
