DOCKER ?= docker
GO ?= go
WATCHMAN_MAKE ?= watchman-make

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

all: clean generate docker-build-operatord

generate: $(PROTOC) $(PROTOC_GEN_GO) $(PROTOC_GEN_OPERATORCTL) $(PROTOC_GEN_OPERATORD)
	find $(GOPATH)/src/bread -type f -name "*.proto" | \
	while read f; do \
		$< \
			-I$(GOPATH)/src/bread \
			-I$(GOPATH)/src/github.com/sr/operator \
			--operatorctl_out=import_path=$(SVC_IMPORT_PATH):$(OPERATORCTL_DIR) \
			--operatord_out=import_path=$(SVC_IMPORT_PATH):$(OPERATORD_DIR) \
			--go_out=plugins=grpc,import_path=$(SVC_IMPORT_PATH),Moperator.proto=$(OPERATOR_PKG),Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=github.com/golang/protobuf/ptypes/duration:$(SVC_DIR) $$f; \
	done

clean:
	rm -f etc/ca-bundle.crt $(OPERATORD_LINUX) $(OPERATORDCTL_DIR)/main-gen.go $(OPERATORD_DIR)/main-gen.go

build-operatord: $(TMPDIR)
	env CGO_ENABLED=0 GOOS=linux $(GO) build -a -tags netgo -ldflags "-w" \
		-o $(OPERATORD_LINUX) bread/cmd/operatord

docker-build-operatord: etc/ca-bundle.crt build-operatord
	cp $(OPERATORD_LINUX) operatord
	$(DOCKER) build -f $(BREAD)/etc/docker/Dockerfile.operatord -t operatord_app $(BREAD)
	rm -f operatord

etc/ca-bundle.crt:
	$(DOCKER) run docker.dev.pardot.com/base/centos:7 cat /etc/pki/tls/certs/ca-bundle.crt > $@

$(PROTOC_GEN_GO):
	$(GO) install -v github.com/golang/protobuf/protoc-gen-go

$(PROTOC_GEN_OPERATORCTL):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorctl

$(PROTOC_GEN_OPERATORD):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatord

.PHONY: \
	build-operatord \
	docker-build-operatord \
	generate \
	clean
