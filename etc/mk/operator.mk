DOCKER ?= docker
GO ?= go
WATCHMAN_MAKE ?= watchman-make
GRPC_RUBY_PLUGIN ?= $(shell which grpc_ruby_plugin)

GOBIN ?= $(GOPATH)/bin
BREAD ?= $(GOPATH)
TMPDIR ?= /tmp

PROTOC ?= $(shell which protoc)
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
PROTOC_GEN_OPERATORCTL ?= $(GOBIN)/protoc-gen-operatorctl
PROTOC_GEN_OPERATORD ?= $(GOBIN)/protoc-gen-operatord
PROTOC_GEN_OPERATORLOCAL ?= $(GOBIN)/protoc-gen-operatorlocal

OPERATORD ?= $(GOPATH)/bin/operatord
OPERATORD_LINUX ?= $(TMPDIR)/operatord_linux
OPERATORCTL ?= $(GOPATH)/bin/operatorctl

OPERATOR_PKG ?= github.com/sr/operator
OPERATOR_DIR ?= $(GOPATH)/src/github.com/sr/operator

OPERATORCTL_DIR ?= $(GOPATH)/src/bread/cmd/operatorctl
OPERATORD_DIR ?= $(GOPATH)/src/bread/cmd/operatord
SVC_DIR ?= $(GOPATH)/src/bread
SVC_IMPORT_PATH ?= bread

generate: $(PROTOC) $(GRPC_RUBY_PLUGIN) $(PROTOC_GEN_GO) $(PROTOC_GEN_OPERATORCTL) $(PROTOC_GEN_OPERATORD)
	$< \
		-I$(GOPATH)/src/bread \
		-I$(GOPATH)/src/github.com/sr/operator \
		--operatorctl_out=import_path=$(SVC_IMPORT_PATH):$(OPERATORCTL_DIR) \
		--operatord_out=import_path=$(SVC_IMPORT_PATH):$(OPERATORD_DIR) \
		--go_out=plugins=grpc,import_path=$(SVC_IMPORT_PATH),Moperator.proto=$(OPERATOR_PKG),Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=github.com/golang/protobuf/ptypes/duration:$(SVC_DIR) \
		$(GOPATH)/src/bread/pb/*.proto
	$< \
		-I$(GOPATH)/src/bread \
		-I$(GOPATH)/src/github.com/sr/operator \
		--ruby_out=src/hal9000/lib \
		--grpc_out=src/hal9000/lib \
		--plugin=protoc-gen-grpc=$(GRPC_RUBY_PLUGIN) \
		--go_out=plugins=grpc,import_path=$(SVC_IMPORT_PATH),Moperator.proto=$(OPERATOR_PKG),Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=github.com/golang/protobuf/ptypes/duration:$(SVC_DIR) \
		$(GOPATH)/src/bread/hal/*.proto

ldap-dev: docker-build-ldap
	$(DOCKER) stop -t 3 operator_ldap >/dev/null || true
	$(DOCKER) rm operator_ldap >/dev/null || true
	$(DOCKER) run --name "operator_ldap" -P -d \
		-v "$(BREAD)/etc/ldap.ldif:/data/ldap.ldif" bread/ldap >/dev/null

test: etc/ldap.ldif ldap-dev
	export LDAP_PORT_389_TCP_PORT="$$(docker inspect -f '{{(index (index .NetworkSettings.Ports "389/tcp") 0).HostPort }}' operator_ldap)"; \
	export LDAP_PORT_389_TCP_ADDR="localhost"; \
	$(GO) test $$($(GO) list bread/... | grep -v bread/vendor) -ldap github.com/sr/operator/...

clean:
	rm -f etc/docker/ca-bundle.crt $(OPERATORD_LINUX) \
		$(OPERATORDCTL_DIR)/main-gen.go $(OPERATORD_DIR)/main-gen.go

build-operatord: $(TMPDIR)
	env CGO_ENABLED=0 GOOS=linux $(GO) build -a -tags netgo -ldflags "-w" \
		-o $(OPERATORD_LINUX) bread/cmd/operatord

docker-build-ldap:
	docker build -f etc/docker/Dockerfile.ldap -t bread/ldap $(BREAD)

docker-build-operatord: etc/docker/ca-bundle.crt $(OPERATORD_LINUX)
	cp $(OPERATORD_LINUX) operatord
	$(DOCKER) build -f $(BREAD)/etc/docker/Dockerfile.operatord -t operatord_app $(BREAD)
	rm -f operatord

etc/docker/ca-bundle.crt:
	$(DOCKER) run docker.dev.pardot.com/base/centos:7 cat /etc/pki/tls/certs/ca-bundle.crt > $@

$(PROTOC_GEN_GO):
	$(GO) install -v github.com/golang/protobuf/protoc-gen-go

$(PROTOC_GEN_OPERATORCTL):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorctl

$(PROTOC_GEN_OPERATORD):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatord

.PHONY: \
	build-operatord \
	clean \
	docker-build-operatord \
	docker-build-ldap \
	generate \
	ldap-dev \
	test
