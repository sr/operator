FROM docker.dev.pardot.com/base/ruby:2.3.0

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

ENV RUBYLIB "/usr/local/bundle/extensions/x86_64-linux/2.3.0-static/grpc-1.0.0/grpc:$RUBYLIB"
RUN echo 'require "grpc_c"' > /usr/local/bundle/gems/grpc-1.0.0/src/ruby/lib/grpc/grpc.rb

ADD . /app
RUN bundle exec rake assets:precompile
CMD ["script/server"]
