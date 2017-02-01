FROM docker.dev.pardot.com/base/php:7.0.8
ARG artifactory_host
ARG dist=el6
ARG php_version=7.0.8-1
ARG teampass_version=2.1.26-final-3

RUN yum install -y \
    cronie \
    supervisor \
    unzip && \
    for package in "php-ldap"; do \
      yum --enablerepo=remi-php70 install -y "${package}-${php_version}.${dist}.remi"; \
      yum versionlock "${package}"; \
    done

RUN mkdir /teampass && \
  cd /teampass && \
  curl -O https://${artifactory_host}/artifactory/pd-tarball/teampass/teampass-${teampass_version}.zip && \
  unzip teampass-${teampass_version}.zip && \
  rm teampass-${teampass_version}.zip && \
  mv TeamPass-${teampass_version} www

#RUN chown -Rf www-data.www-data /teampass/www
#RUN php5enmod ldap

RUN perl -p -i -e "s/max_execution_time = 30/max_execution_time = 120/g" /etc/php.ini
RUN perl -p -i -e "s#Directory /var/www#Directory /teampass/www#g" /etc/httpd/conf/httpd.conf

COPY custom.sh /
RUN /custom.sh

COPY apache-default.conf /etc/httpd/conf.d/teampass.conf
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
