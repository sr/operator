FROM ruby:2.3.0

RUN mkdir /app
WORKDIR /app

COPY plugins/lita-replication-fixing/*.gemspec plugins/lita-replication-fixing/Gemfile /app/plugins/lita-replication-fixing/
COPY Gemfile /app
RUN bundle install
RUN for i in plugins/*; do bundle install "--gemfile=$i/Gemfile"; done

COPY . /app
CMD ["bin/lita"]