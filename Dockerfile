FROM ruby:2.3.0

RUN apt-get update -qq && \
   apt-get install -y build-essential

RUN groupadd -r docker && \
  useradd -r -g docker -d /app -s /sbin/nologin -c "Docker image user" docker

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

ADD . /app

CMD ["script/server"]
