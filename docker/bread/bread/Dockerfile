FROM docker.dev.pardot.com/base/ruby:2.3.0
ARG artifactory_host
ENV BRAKEMAN_VERSION=3.2.1
ENV BUNDLER_AUDIT_VERSION=0.5.0
ENV GOLANG_VERSION=1.6.2
ENV GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256=e40c36ae71756198478624ed1bb4ce17597b3c19d243f3f0899bb5740d56212a
ENV JFROG_CLI_VERSION=1.1.0
ENV JFROG_CLI_SHA256=e7b47d08bb1b1cc506f3334dfafeac28c4e3886412b6527d12ceed61bd28007e
ENV JFROG_CLI_URL=https://bintray.com/jfrog/jfrog-cli-go/download_file?file_path=${JFROG_CLI_VERSION}%2Fjfrog-cli-linux-amd64%2Fjfrog
ENV RUBOCOP_VERSION=0.40.0
ENV RUBYGEMS_SOURCE=https://${artifactory_host}/artifactory/api/gems/pd-gem/
ENV TERRAFORM_VERSION=0.6.15
ENV TERRAFORM_SHA256=2a81faa54ed6c5e7c065444617fc999f0ab6d433e4e03a0ad599892e74ffff6b
ENV TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV GOPATH=/go
ENV PATH=/data/bin:/data/src/build/docker:$GOPATH/bin:/usr/local/go/bin:$PATH
VOLUME ["/data", "/go"]
WORKDIR "/data"
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 00777 "$GOPATH"
RUN \
  yum install -y unzip \
  && \
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
    curl -fsSL "$TERRAFORM_URL" -o /tmp/terraform.zip \
  && \
    echo "$TERRAFORM_SHA256  /tmp/terraform.zip" | sha256sum -c - \
  && \
    unzip /tmp/terraform.zip -d /usr/bin \
  && \
    rm -f /tmp/terraform.zip \
  && \
    gem install \
      --no-ri --no-rdoc \
      --source "${RUBYGEMS_SOURCE}" \
      "brakeman:${BRAKEMAN_VERSION}" \
      "bundler-audit:${BUNDLER_AUDIT_VERSION}" \
      "rubocop:${RUBOCOP_VERSION}" \
  && \
    bundle-audit update
