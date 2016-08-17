FROM docker.dev.pardot.com/base/ruby:2.3.0
ARG artifactory_host
ENV BRAKEMAN_VERSION=3.2.1
ENV BUNDLER_AUDIT_VERSION=0.5.0
ENV GOLANG_VERSION=1.7
ENV GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256=702ad90f705365227e902b42d91dd1a40e48ca7f67a2f4b2fd052aaa4295cd95
ENV JFROG_CLI_VERSION=1.3.2
ENV JFROG_CLI_SHA256=806b06c9240d6dc28492ee28c7c3f14881c3fb05268329b47fee93e7b7210476
ENV JFROG_CLI_URL=https://bintray.com/jfrog/jfrog-cli-go/download_file?file_path=${JFROG_CLI_VERSION}%2Fjfrog-cli-linux-amd64%2Fjfrog
ENV RUBOCOP_VERSION=0.40.0
ENV RUBYGEMS_SOURCE=https://${artifactory_host}/artifactory/api/gems/pd-gem/
ENV GOPATH=/go
ENV PATH=/data/bin:/data/src/build/docker:$GOPATH/bin:/usr/local/go/bin:$PATH
VOLUME ["/data", "/go"]
WORKDIR "/data"
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 00777 "$GOPATH"
RUN \
  curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && \
    echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && \
    tar -C /usr/local -xzf golang.tar.gz \
  && \
    rm golang.tar.gz \
  && \
    curl -fsSL $JFROG_CLI_URL -o /usr/bin/jfrog \
  && \
    echo "$JFROG_CLI_SHA256  /usr/bin/jfrog" | sha256sum -c - \
  && \
    chmod +x /usr/bin/jfrog \
  && \
    mkdir -p ~/.jfrog/security \
  && \
    cp /etc/pki/tls/certs/ca-bundle.crt ~/.jfrog/security \
  && \
    gem install \
      --no-ri --no-rdoc \
      --source "${RUBYGEMS_SOURCE}" \
      "brakeman:${BRAKEMAN_VERSION}" \
      "bundler-audit:${BUNDLER_AUDIT_VERSION}" \
      "rubocop:${RUBOCOP_VERSION}" \
  && \
    bundle-audit update
