FROM ruby:2.1.5
ENV LANG C.UTF-8

RUN apt-get update -qq && \
   apt-get install -y build-essential && \
   apt-get install -y cron && \
   apt-get install -y rsync

RUN groupadd -r docker && \
  useradd -r -g docker -d /pull-agent -s /sbin/nologin -c "Docker image user" docker

RUN mkdir /pull-agent
RUN mkdir /var/lock/pull-agent
WORKDIR /pull-agent

ADD Gemfile /pull-agent/Gemfile
ADD Gemfile.lock /pull-agent/Gemfile.lock
RUN bundle install

ADD . /pull-agent
ADD docker/crontab /etc/cron.d/pull-agent

# CMD crond -n # on CentOS
CMD docker/cron.sh && tail -f /var/log/cron.log
