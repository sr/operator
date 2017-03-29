FROM docker.dev.pardot.com/base/centos:6

# https://git.dev.pardot.com/Pardot/chef/blob/master/cookbooks/pardot_php70/attributes/default.rb
ARG dist=el6
ARG libzookeeper_version=3.4.6-1.pardot
ARG git_version=2.6.4-1
ARG php_version=7.0.8-1
ARG php_packages="php-json php-common php-cli php-devel php php-mcrypt php-mbstring php-pdo php-xml php-xmlrpc php-imap php-gd php-tidy php-bcmath php-intl php-opcache php-mysqlnd php-process php-ldap"
ARG artifactory_host

# PHP
COPY remi-php70.repo remi-safe.repo /etc/yum.repos.d/
RUN yum install -y epel-release && \
  yum install -y httpd mod_ssl yum-versionlock openssh-clients which less && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/git-${git_version}.${dist}.x86_64.rpm" && \
  yum --nogpgcheck localinstall -y "https://${artifactory_host}/artifactory/pd-stacki/RedHat/RPMS/libzookeeper-devel-${libzookeeper_version}.${dist}.x86_64.rpm" && \
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

# Save public key information for remote Git servers
COPY known_hosts /etc/ssh/ssh_known_hosts
RUN chmod 0600 /etc/ssh/ssh_known_hosts
