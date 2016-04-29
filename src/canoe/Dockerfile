FROM docker.dev.pardot.com/base/ruby:2.3.0
ENV LANG C.UTF-8

RUN apt-get update -qq && \
   apt-get install -y build-essential && \
   apt-get install -y nodejs && \
   apt-get install -y netcat

RUN groupadd -r docker && \
  useradd -r -g docker -d /app -s /sbin/nologin -c "Docker image user" docker

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
ADD vendor/cache /app/vendor/cache
RUN bundle install --local

ADD . /app
RUN bundle exec rake assets:precompile

CMD ["script/server"]
