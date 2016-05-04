GO ?= go
GOBIN ?= $(GOPATH)/bin
OPERATORC ?= $(GOBIN)/operatorc
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
DOCKER ?= docker

OPERATORCTL ?= $(GOBIN)/operatorctl
OPERATORD ?= $(GOBIN)/operatord
OPERATORCTL_SRC ?= cmd/operatorctl/main-gen.go
OPERATORD_SRC ?= $(shell find cmd/operatord -type f -name "*.go")

OPERATORD_ADDRESS ?= localhost:3000
export OPERATORD_ADDRESS

IMPORTPATH ?= chatops

build: $(OPERATORC) $(PROTOC_GEN_GO)
	$< \
		--import-path $(IMPORTPATH) \
		--cmd-out cmd/operatorctl \
		--server-out cmd/operatord \
		.

docker-build:
	$(DOCKER) run --rm  \
		-v "$(shell pwd):/in" \
		-v "$(shell pwd):/out" \
		srozet/operatorc:3b62142 \
			--import-path $(IMPORTPATH) \
			--cmd-out /out/cmd/operatorctl \
			--server-out /out/cmd/operatord \
			/in

$(PROTOC_GEN_GO):
	$(GO) install -v vendor/github.com/golang/protobuf/protoc-gen-go

.PHONY: \
	build \
	docker-build
