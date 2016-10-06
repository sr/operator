FROM docker.dev.pardot.com/base/ruby:2.3.0
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY vendor/cache /app/vendor/cache
RUN bundler install --local
PORT 9091
ADD . /app
ENV RUBYLIB "/usr/local/bundle/extensions/x86_64-linux/2.3.0-static/grpc-1.0.0/grpc:$RUBYLIB"
RUN echo 'require "grpc_c"' > /usr/local/bundle/gems/grpc-1.0.0/src/ruby/lib/grpc/grpc.rb
CMD ["script/server"]
