GO ?= go
GOBIN ?= $(GOPATH)/bin
OPERATORC ?= $(GOBIN)/operatorc
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
PROTOC_GEN_OPERATORCMD ?= $(GOBIN)/protoc-gen-operatorcmd
PROTOC_GEN_OPERATORD ?= $(GOBIN)/protoc-gen-operatord
DOCKER ?= docker

OPERATORCTL ?= $(GOBIN)/operatorctl
OPERATORD ?= $(GOBIN)/operatord
OPERATORCTL_SRC ?= cmd/operatorctl/main-gen.go
OPERATORD_SRC ?= $(shell find cmd/operatord -type f -name "*.go")

OPERATORD_ADDRESS ?= localhost:3000
export OPERATORD_ADDRESS

IMPORTPATH ?= chatops

build: $(OPERATORC) $(PROTOC_GEN_OPERATORCMD) $(PROTOC_GEN_OPERATORD) $(PROTOC_GEN_GO)
	$< \
		--import-path $(IMPORTPATH) \
		--cmd-out cmd/operatorctl \
		--server-out cmd/operatord \
		.

clean:
	go clean -i ./...
	rm -f \
		$(OPERATORC) \
		$(PROTOC_GEN_OPERATORCMD) \
		$(PROTOC_GEN_OPERATORD) \
		$(PROTOC_GEN_GO)

docker-build:
	$(DOCKER) run --rm  \
		-v "$(shell pwd):/in" \
		-v "$(shell pwd):/out" \
		srozet/operatorc:3b62142 \
			--import-path $(IMPORTPATH) \
			--cmd-out /out/cmd/operatorctl \
			--server-out /out/cmd/operatord \
			/in

$(OPERATORC):
	$(GO) install -v github.com/sr/operator/cmd/operatorc

$(PROTOC_GEN_GO):
	$(GO) install -v vendor/github.com/golang/protobuf/protoc-gen-go

$(PROTOC_GEN_OPERATORCMD):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorcmd

$(PROTOC_GEN_OPERATORD):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatord

.PHONY: \
	build \
	clean \
	docker-build
