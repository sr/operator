GO ?= go
GOBIN ?= $(GOPATH)/bin
GOFMT ?= $(shell which gofmt)
GOLINT ?= $(GOBIN)/golint
DEADLEAVES ?= $(GOBIN)/deadleaves
ERRCHECK = $(GOBIN)/errcheck
INTERFACER = $(GOBIN)/interfacer
UNUSED = $(GOBIN)/unused

PACKAGES ?= $(shell $(GO) list ./...)

all: deps fmt lint vet errcheck test install interfacer unused

ci: clean all

install:
	$(GO) install -v $(PACKAGES)

test:
	$(GO) test -race $(PACKAGES)

clean:
	$(GO) clean -i ./...

deps:
	$(GO) get \
		github.com/acsellers/inflections \
		github.com/golang/protobuf/proto \
		github.com/golang/protobuf/ptypes/duration \
		github.com/golang/protobuf/ptypes/timestamp \
		github.com/kr/text \
		github.com/matttproud/golang_protobuf_extensions/pbutil \
		github.com/satori/go.uuid \
		github.com/serenize/snaker \
		google.golang.org/grpc \
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
		@	for pkg in $(PACKAGES); do \
				out="$$($< $$pkg | grep -v -E 'should have comment|\.pb\.go|\-gen\.go')"; \
				if [ -n "$$out" ]; then \
					echo "lint: $$out"; \
					exit 1; \
				fi; \
			done

unused: $(UNUSED)
	$< $(PACKAGES)

vet:
	$(GO) vet $(PACKAGES)

errcheck: $(ERRCHECK)
	@ for pkg in $(PACKAGES); do \
			out="$$($< $$pkg | grep -v -E 'main-gen\.go|_test\.go')"; \
			if [ -n "$$out" ]; then \
				echo "$$out"; \
				fail=true; \
			fi; \
	  done; \
	  test $$fail && exit 1; true

interfacer: $(INTERFACER)
	$< $(PACKAGES)

$(DEADLEAVES):
	$(GO) get -v github.com/nf/deadleaves

$(ERRCHECK):
	$(GO) get -v github.com/kisielk/errcheck

$(GOLINT):
	$(GO) get -v github.com/golang/lint/golint

$(INTERFACER):
	$(GO) get -v github.com/mvdan/interfacer/cmd/interfacer

$(UNUSED):
	$(GO) get -v github.com/dominikh/go-unused/cmd/unused

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
	unused \
	vet
