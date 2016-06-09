GO ?= go
PROTOC ?= protoc
GOBIN ?= $(GOPATH)/bin
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go

PATH := $(GOBIN):$(PATH)

$(PROTOC_GEN_GO):
	$(GO) install -v vendor/github.com/golang/protobuf/protoc-gen-go

privet.pb.go: $(PROTOC_GEN_GO) privet.proto
	$(PROTOC) privet.proto --go_out=plugins=grpc:.
