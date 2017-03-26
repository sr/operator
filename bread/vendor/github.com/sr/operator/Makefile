GO ?= go
GOBIN ?= $(GOPATH)/bin
GOFMT ?= $(shell which gofmt)
GOLINT ?= $(GOBIN)/golint
DEADLEAVES ?= $(GOBIN)/deadleaves
ERRCHECK = $(GOBIN)/errcheck
INTERFACER = $(GOBIN)/interfacer
PROTOC ?= $(shell which protoc)
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
UNUSED = $(GOBIN)/unused
PROTO_INCLUDE ?= $(shell brew --prefix protobuf)/include

all: deps fmt lint vet errcheck test install interfacer unused

ci: clean all

install:
	$(GO) install -v ./...

test:
	$(GO) test -race ./...

clean:
	$(GO) clean -i ./...

proto: $(PROTOC) $(PROTOC_GEN_GO)
	$< -I. -I$(PROTO_INCLUDE) --go_out=Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=github.com/golang/protobuf/ptypes/duration:. operator.proto
	$< -I. -I$(PROTO_INCLUDE) --go_out=Moperator.proto=github.com/sr/operator,plugins=grpc,import_path=testing:. testing/*.proto

deps:
	$(GO) get \
		github.com/dvsekhvalnov/jose2go \
		github.com/golang/protobuf/proto \
		github.com/golang/protobuf/ptypes/duration \
		github.com/golang/protobuf/ptypes/timestamp \
		github.com/kr/text \
		google.golang.org/grpc \
		golang.org/x/oauth2/clientcredentials \
		golang.org/x/net/context

fmt: $(GOFMT)
	@ for file in $$(find . -name '*.go' | grep -v -E '\.pb\.go$$'); do \
			out="$$($< -s -d $$file)"; \
			if [ $$? -ne 0 ]; then \
				echo "fmt: $$out"; \
				exit 1; \
			fi; \
			if [ -n "$$out" ]; then \
				echo "fmt: $$out"; \
				exit 1; \
			fi; \
	  done

lint: $(GOLINT)
	@	for pkg in $$($(GO) list ./...); do \
			out="$$($< $$pkg | grep -v -E 'should have comment|\.pb\.go|\-gen\.go')"; \
			if [ -n "$$out" ]; then \
				echo "lint: $$out"; \
				exit 1; \
			fi; \
		done

unused: $(UNUSED)
	$< ./...

vet:
	$(GO) vet ./...

errcheck: $(ERRCHECK)
	@ $< ./..

interfacer: $(INTERFACER)
	$< ./...

$(ERRCHECK):
	$(GO) get -v github.com/kisielk/errcheck

$(GOLINT):
	$(GO) get -v github.com/golang/lint/golint

$(INTERFACER):
	$(GO) get -v github.com/mvdan/interfacer/cmd/interfacer

$(PROTOC_GEN_GO):
	$(GO) get -v github.com/golang/protobuf/protoc-gen-go

$(UNUSED):
	$(GO) get -v honnef.co/go/unused/cmd/unused

.PHONY: \
	all \
	build \
	ci \
	deps \
	errcheck \
	fmt \
	install \
	interfacer \
	lint \
	proto \
	unused \
	vet
