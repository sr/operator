FROM docker.dev.pardot.com/base/ruby:2.3.0
ENV LANG C.UTF-8

ENV BUNDLE_APP_CONFIG=

COPY plugins/lita-replication-fixing/*.gemspec plugins/lita-replication-fixing/Gemfile* /app/plugins/lita-replication-fixing/
COPY plugins/lita-zabbix/*.gemspec plugins/lita-zabbix/Gemfile* /app/plugins/lita-zabbix/
COPY plugins/lita-commit/*.gemspec plugins/lita-commit/Gemfile* /app/plugins/lita-commit/
COPY Gemfile* /app/

RUN bundle install
RUN for i in plugins/*; do cd "$i"; bundle install; cd ../..; done

COPY . /app
CMD ["bundle", "exec", "lita"]
