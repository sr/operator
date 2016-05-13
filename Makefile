GO ?= go
GOBIN ?= $(GOPATH)/bin
GOFMT ?= gofmt
GOLINT ?= $(GOBIN)/golint
ERRCHECK ?= $(GOBIN)/errcheck
PACKAGES = $(shell go list ./... | grep -v -E '^vendor|chatoops' | sort -r)

all: deps fmt lint vet errcheck deps install

deps:
	go get -d ./...

install:
	go install -v $(PACKAGES)

fmt:
	@ for file in $$(find . -name '*.go' | grep -v -E '^./vendor|\.pb\.go$$'); do \
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
	@ for file in $$(find . -name '*.go' | grep -v -E '^./vendor|\-gen\.go$$|^./github.com/sr/protolog|\.pb\.go$$'); do \
			out="$$($< $$file | grep -v 'should have comment')"; \
			if [ -n "$$out" ]; then \
				echo "lint: $$out"; \
				exit 1; \
			fi \
	  done

vet:
	@ for pkg in $(PACKAGES); do \
			out="$$($(GO) vet $$pkg)"; \
			if [ $$? -ne 0 ]; then \
				exit 1; \
			fi; \
			if [ -n "$$out" ]; then \
				exit 1; \
			fi \
	  done

errcheck: $(ERRCHECK)
	@ for pkg in $(PACKAGES); do \
			$< $$pkg; \
			if [ $$? -ne 0 ]; then \
				fail=true; \
			fi; \
	  done; \
	  test $$fail && exit 1; true

$(ERRCHECK):
	$(GO) get github.com/kisielk/errcheck

$(GOLINT):
	$(GO) get github.com/golang/lint/golint

.PHONY: \
	all \
	install \
	deps \
	fmt \
	lint \
	vet \
	errcheck
