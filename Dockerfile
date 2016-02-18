FROM ruby:2.3.0

RUN mkdir /app
WORKDIR /app

COPY plugins/lita-replication-fixing/*.gemspec plugins/lita-replication-fixing/Gemfile /app/plugins/lita-replication-fixing/
COPY Gemfile /app
COPY Gemfile.lock /app
RUN bundle install

COPY . /app
CMD ["bundle", "exec", "lita"]