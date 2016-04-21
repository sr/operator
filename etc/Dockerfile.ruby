# TODO(sr) Switch to our base image once it is ready
FROM ruby:2.3.0
RUN gem install rubocop
ENV PATH "/repo/bin:$PATH"
VOLUME "/repo"
WORKDIR "/repo"
