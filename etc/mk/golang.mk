GO ?= go
GOBIN ?= $(GOPATH)/bin
GOFMT ?= gofmt
GOLINT ?= $(GOBIN)/golint
ERRCHECK = $(GOBIN)/errcheck
INTERFACER = $(GOBIN)/interfacer
UNUSED = $(GOBIN)/unused

PACKAGES = $(shell go list ./src/... | grep -v -E '^vendor|chatoops' | sort -r)

all: fmt lint unused vet errcheck interfacer install

install:
	go install -race -v $(PACKAGES)

fmt:
	@ for file in $$(find src -name '*.go' | grep -v -E '^src/vendor|\.pb\.go$$'); do \
			out="$$($(GOFMT) -s -d $$file)"; \
			if [ $$? -ne 0 ]; then \
				echo "fmt: $$out"; \
				exit 1; \
			fi; \
			if [ -n "$$out" ]; then \
				echo "fmt: $$out"; \
				exit 1; \
			fi \
	  done

lint: $(GOLINT)
	@ for file in $$(find src -name '*.go' | grep -v -E '^src/vendor|\-gen\.go$$|\.pb\.go$$'); do \
			out="$$($< $$file | grep -v 'should have comment')"; \
			if [ -n "$$out" ]; then \
				echo "lint: $$out"; \
				exit 1; \
			fi \
	  done

unused: $(UNUSED)
	$< -fields $(shell go list ./src/... | grep -v -E '^vendor|chatoops' | sort -r)

vet:
	@ for pkg in $(PACKAGES); do \
			go vet $$pkg; \
	  done

errcheck: $(ERRCHECK)
	@ for pkg in $(PACKAGES); do \
			$< $$pkg; \
			if [ $$? -ne 0 ]; then \
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
	$(GO) install vendor/github.com/kisielk/errcheck

$(GOLINT):
	$(GO) install vendor/github.com/golang/lint/golint

$(INTERFACER):
	$(GO) install vendor/github.com/mvdan/interfacer/cmd/interfacer

$(UNUSED):
	$(GO) install vendor/honnef.co/go/unused/cmd/unused

.PHONY: \
	all \
	fmt \
	lint \
	vet \
	errcheck
