FROM ruby:2.3.1

WORKDIR /app

RUN \
  apt-get update -qq \
  && \
    apt-get install -y \
      nodejs \
      libpq-dev \
  && \
    update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10 \
  && \
    apt-get clean

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
ADD vendor/cache /app/vendor/cache
RUN bundle install --local --binstubs

ADD . /app
RUN bundle exec rake assets:precompile
