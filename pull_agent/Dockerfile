FROM docker.dev.pardot.com/base/ruby:2.3.0

RUN \
  yum install -y \
    cronie \
    rsync \
    supervisor \
  && \
    groupadd -r docker \
  && \
    useradd -r -g docker -d /pull-agent -s /sbin/nologin -c "Docker image user" docker

RUN mkdir /pull-agent /var/lock/pull-agent && \
  touch /var/log/cron.log
WORKDIR /pull-agent

ENV RUBYGEM_VERSION 1
ADD Gemfile /pull-agent/Gemfile
ADD pardot_pull-agent.gemspec /pull-agent/pardot_pull-agent.gemspec
RUN bundle install

ADD . /pull-agent
ADD docker/crontab /etc/cron.d/pull-agent

CMD ["supervisord", "-n", "-c", "docker/supervisor.conf"]
