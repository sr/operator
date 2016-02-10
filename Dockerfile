FROM ruby:2.3.0

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/Gemfile
RUN bundle install

ADD . /app

CMD ["lita"]