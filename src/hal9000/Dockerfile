FROM docker.dev.pardot.com/base/ruby:2.3.0

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY vendor/cache /app/vendor/cache
RUN bundler install --local

ADD . /app

CMD ["script/server"]
