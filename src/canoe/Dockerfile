FROM docker.dev.pardot.com/base/ruby:2.3.0
ENV LANG en_US.UTF-8

RUN \
  yum install -y \
   nodejs \
   nc \
  && \
    groupadd -r docker \
  && \
    useradd -r -g docker -d /app -s /sbin/nologin -c "Docker image user" docker

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
ADD vendor/cache /app/vendor/cache
RUN bundle install --local

ADD . /app
RUN bundle exec rake assets:precompile

CMD ["script/server"]
