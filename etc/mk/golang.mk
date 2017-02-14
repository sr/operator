GO ?= go
GOBIN ?= $(GOPATH)/bin
GOFMT ?= $(shell which gofmt)
GOLINT ?= $(GOBIN)/golint
DEADLEAVES ?= $(GOBIN)/deadleaves
ERRCHECK = $(GOBIN)/errcheck
INTERFACER = $(GOBIN)/interfacer
UNUSED = $(GOBIN)/unused

PACKAGES ?= $(shell $(GO) list ./... | grep -v vendor)

all: install test fmt lint vet errcheck interfacer unused

install:
	$(GO) install -v $$($(GO) list ./...)

test:
	$(GO) test -race $(PACKAGES)

clean:
	$(GO) clean -i ./...

fmt: $(GOFMT)
	@ for file in $$(find src -name '*.go' | grep -v -E 'vendor/|\.pb\.go$$'); do \
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
			out="$$($< $$pkg | grep -v -E 'swagger|main-gen\.go|_test\.go')"; \
			if [ -n "$$out" ]; then \
				echo "$$out"; \
				fail=true; \
			fi; \
	  done; \
	  test $$fail && exit 1; true

interfacer: $(INTERFACER)
	$< $(PACKAGES)

$(ERRCHECK):
	$(GO) install -v ./vendor/github.com/kisielk/errcheck

$(GOLINT):
	$(GO) install -v ./vendor/github.com/golang/lint/golint

$(INTERFACER):
	$(GO) install -v ./vendor/github.com/mvdan/interfacer/cmd/interfacer

$(UNUSED):
	$(GO) install -v ./vendor/honnef.co/go/unused/cmd/unused

.PHONY: \
	all \
	build \
	errcheck \
	fmt \
	install \
	interfacer \
	lint \
	unused \
	vet
