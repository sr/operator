FROM docker.dev.pardot.com/base/centos:7

ARG rmux_version=0.3.3.1
ARG go_version=1.5.3
ARG artifactory_host

ENV GOROOT=/usr/local/go
ENV GOPATH=/tmp/gopath

RUN yum install -y epel-release && \
  yum install -y supervisor less which git && \
  yum clean all

RUN curl https://storage.googleapis.com/golang/go${go_version}.linux-amd64.tar.gz | tar -xvz -C /usr/local && \
  mkdir -p "$GOPATH" && \
  cd "$GOPATH" && \
  mkdir -p src/github.com/SalesforceEng/rmux && \
  git clone https://github.com/SalesforceEng/rmux src/github.com/SalesforceEng/rmux && \
  cd src/github.com/SalesforceEng/rmux && \
  git checkout ${rmux_version} && \
  "$GOROOT/bin/go" get -u && \
  "$GOROOT/bin/go" build -o /usr/local/bin/rmux ./main && \
  cd / && \
  rm -rf "$GOPATH" && \
  rm -rf "$GOROOT"

RUN groupadd -r rmux -g 533 && \
  useradd -r -g rmux -d /var/lib/rmux -s /sbin/nologin -c "Rmux" -u 533 rmux

RUN mkdir -p /var/lib/rmux && \
  chown -R rmux:rmux /var/lib/rmux

ADD rmux.json /etc/rmux.json

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME ["/var/lib/rmux"]
USER rmux
CMD ["/usr/local/bin/rmux", "-config=/etc/rmux.json"]
