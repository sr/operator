FROM ruby:2.3.0
ENV LANG C.UTF-8

RUN \
  apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    build-essential \
    mysql-client \
    php5 \
    php5-dev \
    php-pear \
    nodejs \
    netcat \
  && pecl install yaml \
  && echo "extension=yaml.so" >> /etc/php5/cli/php.ini

RUN groupadd -r docker && \
  useradd -r -g docker -d /app -s /sbin/nologin -c "Docker image user" docker

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
ADD vendor/cache /app/vendor/cache
RUN bundle install --local

ADD . /app
RUN bundle exec rake assets:precompile

CMD ["script/server"]
