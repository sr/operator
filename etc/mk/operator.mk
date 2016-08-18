DOCKER ?= docker
GO ?= go
GOBIN ?= $(GOPATH)/bin
TMPDIR ?= /tmp

OPERATOR_DIR ?= $(GOPATH)/src/github.com/sr/operator
OPERATOR_PROTO ?= $(OPERATOR_DIR)/operator.proto
OPERATOR_IMPORT_PATH ?= bread
OPERATORD ?= $(GOPATH)/bin/operatord
OPERATORD_LINUX ?= $(TMPDIR)/operatord
OPERATORCTL ?= $(GOPATH)/bin/operatorctl
OPERATORCTL_GEN_SRC ?= $(GOPATH)/src/bread/cmd/operatorctl/main-gen.go
OPERATORD_GEN_SRC ?= $(GOPATH)/src/bread/cmd/operatord/builder-gen.go

SVC_DIR ?= $(GOPATH)/src/bread

-include $(GOPATH)/src/github.com/sr/operator/operator.mk

build-operatord-linux: $(TMPDIR)
	env CGO_ENABLED=0 GOOS=linux \
		$(GO) build -a -tags netgo -ldflags '-w' \
			-o $(TMPDIR)/operatord_linux bread/cmd/operatord

generate: operator-generate

clean: operator-clean
	rm -f $(OPERATORD_LINUX) etc/ca-bundle.crt

docker-build-operatord: etc/ca-bundle.crt
	$(DOCKER) build -f $(BREAD)/etc/docker/Dockerfile.operatord -t operatord_app $(BREAD)

etc/ca-bundle.crt:
	$(DOCKER) run docker.dev.pardot.com/base/centos:7 cat /etc/pki/tls/certs/ca-bundle.crt > $@

.PHONY: \
	build-operatord \
	docker-build-operatord \
	generate \
	clean
