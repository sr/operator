# TODO(sr) Switch to our base image once it is ready
FROM ruby:2.3.0
ENV PATH "/data/bin:$PATH"
VOLUME ["/data"]
WORKDIR "/data"
RUN gem install rubocop
