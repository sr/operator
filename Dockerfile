FROM ruby:2.3.0

RUN mkdir /app
WORKDIR /app

ENV BUNDLE_APP_CONFIG=

COPY plugins/lita-replication-fixing/*.gemspec plugins/lita-replication-fixing/Gemfile /app/plugins/lita-replication-fixing/
COPY Gemfile /app
COPY Gemfile.lock /app

RUN bundle install
RUN for i in plugins/*; do cd "$i"; bundle install; cd ../..; done

COPY . /app
CMD ["bundle", "exec", "lita"]