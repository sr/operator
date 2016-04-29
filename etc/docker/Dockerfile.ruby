FROM docker.dev.pardot.com/base/ruby:2.3.0
ENV PATH "/data/bin:$PATH"
VOLUME ["/data"]
WORKDIR "/data"
RUN gem install rubocop
