GO ?= go
GOBIN ?= $(GOPATH)/bin
OPERATORC ?= $(GOBIN)/operatorc
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
DOCKER ?= docker

OPERATOR ?= $(GOBIN)/pistolet
OPERATORD ?= $(GOBIN)/pistoletd
OPERATOR_SRC ?= cmd/pistolet/main-gen.go
OPERATORD_SRC ?= $(shell find cmd/pistoletd -type f -name "*.go")

OPERATORD_ADDRESS ?= localhost:3000
export OPERATORD_ADDRESS

IMPORTPATH ?= chatops

build: $(OPERATORC) $(PROTOC_GEN_GO)
	$< \
		--import-path $(IMPORTPATH) \
		--cmd-out cmd/pistolet \
		--server-out cmd/pistoletd \
		.

docker-build:
	$(DOCKER) run --rm  \
		-v "$(shell pwd):/in" \
		-v "$(shell pwd):/out" \
		srozet/operatorc:3b62142 \
			--import-path $(IMPORTPATH) \
			--cmd-out /out/cmd/pistolet \
			--server-out /out/cmd/pistoletd \
			/in

$(PROTOC_GEN_GO):
	$(GO) install -v github.com/golang/protobuf/protoc-gen-go

.PHONY: \
	build \
	docker-build
