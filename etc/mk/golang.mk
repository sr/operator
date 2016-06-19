GO ?= go
GOBIN ?= $(GOPATH)/bin
GOFMT ?= gofmt
GOLINT ?= $(GOBIN)/golint
ERRCHECK = $(GOBIN)/errcheck
INTERFACER = $(GOBIN)/interfacer
UNUSED = $(GOBIN)/unused

PACKAGES = $(shell $(GO) list privet/... chatops/...)
TOOLS = $(shell $(GO) list golang.org/x/tools/cmd/...)

all: fmt lint unused vet interfacer errcheck install build

install:
	$(GO) install -race -v $(PACKAGES)

build:
	$(GO) build ./...

install-tools:
	$(GO) install -v $(TOOLS)

fmt:
	@ for file in $$(find src -name '*.go' | grep -v -E '\.pb\.go$$'); do \
			out="$$($(GOFMT) -s -d $$file)"; \
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
	@ for pkg in $(PACKAGES); do \
			$< -fields $$pkg; \
			if [ $$? -ne 0 ]; then \
				fail=true; \
			fi; \
		done; \
		test $$fail && exit 1; true

vet:
	@ for pkg in $(PACKAGES); do \
			$(GO) vet $$pkg; \
	  done

errcheck: $(ERRCHECK)
	@ for pkg in $(PACKAGES); do \
			out="$$($< $$pkg | grep -v -E 'main-gen\.go')"; \
			if [ -n "$$out" ]; then \
				echo "$$out"; \
				fail=true; \
			fi; \
	  done; \
	  test $$fail && exit 1; true

interfacer: $(INTERFACER)
	@ for pkg in $(PACKAGES); do \
			$< $$pkg; \
			if [ $$? -ne 0 ]; then \
				fail=true; \
			fi; \
	  done; \
	  test $$fail && exit 1; true

$(ERRCHECK):
	$(GO) install -v github.com/kisielk/errcheck

$(GOLINT):
	$(GO) install -v github.com/golang/lint/golint

$(INTERFACER):
	$(GO) install -v github.com/mvdan/interfacer/cmd/interfacer

$(UNUSED):
	$(GO) install -v honnef.co/go/unused/cmd/unused

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
