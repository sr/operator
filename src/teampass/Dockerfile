FROM docker.dev.pardot.com/base/bread/teampass:2.1.25.2
# You'll need to update custom.sh if this version is changed

COPY docker-entrypoint.sh /
COPY apache-default.conf /etc/apache2/sites-available/000-default.conf
COPY custom.sh /
RUN /custom.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
