FROM docker.dev.pardot.com/base/ruby:2.3.0-centos6

RUN \
  yum install -y \
    nodejs \
    nc

RUN groupadd -r docker && \
  useradd -r -g docker -d /app -s /sbin/nologin -c "Docker image user" docker

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY vendor/cache /app/vendor/cache
RUN bundler install --local

ADD . /app
RUN bundler exec rake assets:precompile

CMD ["script/server"]
