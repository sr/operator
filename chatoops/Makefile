GOBIN ?= $(GOPATH)/bin
OPERATORC ?= $(GOBIN)/operatorc
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go

IMPORTPATH ?= github.com/sr/operator/chatoops

build: $(OPERATORC)
	$< \
		--import-path $(IMPORTPATH)/services \
		--cmd-out cmd/operator \
		--hubot-out hubot/scripts \
		--server-out cmd/operatord \
		services

$(OPERATORC): $(PROTOC_GEN_GO)
	go install -v github.com/sr/operator/cmd/...

$(PROTOC_GEN_GO):
	get install -v github.com/golang/protobuf/protoc-gen-go

.PHONY: \
	build
