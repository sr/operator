FROM docker.dev.pardot.com/base/centos:7

ARG artifactory_host
ARG ruby_version=2.3.0
ARG bundler_version=1.12.1

ENV BUNDLE_SILENCE_ROOT_WARNING=1
ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_APP_CONFIG=/usr/local/bundle

RUN yum install -y epel-release tar gcc gcc-c++ make git patch autoconf gdbm-devel ncurses-devel libffi-devel openssl-devel libyaml-devel readline-devel mysql-devel nc nmap && \
  yum --enablerepo=epel install -y nodejs && \
  curl -L -o "/tmp/ruby-${ruby_version}.tar.gz" "http://cache.ruby-lang.org/pub/ruby/2.3/ruby-${ruby_version}.tar.gz" && \
  tar -xvzf "/tmp/ruby-${ruby_version}.tar.gz" && \
  cd "ruby-${ruby_version}" && \
  ./configure --with-out-ext=tcl --with-out-ext=tk && \
  make && \
  make install && \
  cd /tmp && \
  rm -rf "/tmp/ruby-${ruby_version}.tar.gz" "/tmp/ruby-${ruby_version}" && \
  gem install bundler -v ${bundler_version} && \
  mkdir -p "/usr/local/bundle" "/app"

WORKDIR /app
