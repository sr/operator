FROM docker.dev.pardot.com/base/ruby:2.3.0

RUN \
  yum install -y \
    php5 \
    php-pear \
    nodejs \
    nc \
    php-pecl-yaml

RUN groupadd -r docker && \
  useradd -r -g docker -d /app -s /sbin/nologin -c "Docker image user" docker

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY vendor/cache /app/vendor/cache
RUN bundle install --local

ADD . /app
RUN bundle exec rake assets:precompile

CMD ["script/server"]
