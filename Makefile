GO ?= go
GOBIN ?= $(GOPATH)/bin
GOFMT ?= gofmt
GOLINT ?= $(GOBIN)/golint
ERRCHECK = $(GOBIN)/errcheck
INTERFACER = $(GOBIN)/interfacer
UNUSED = $(GOBIN)/unused

PACKAGES ?= $(shell go list ./...)
SRC ?= $(shell find . -name '*.go' | sort)

all: fmt lint vet errcheck interfacer unused install

ci: clean all

clean:
	$(GO) clean -i $(PACKAGES)

install:
	go install -race -v $(PACKAGES)

fmt:
	@ for file in $(SRC); do \
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

unused: $(UNUSED)
	@ for pkg in $(PACKAGES); do \
			$< -fields $$pkg; \
			if [ $$? -ne 0 ]; then \
				fail=true; \
			fi; \
		done; \
		test $$fail && exit 1; true

vet:
	@ $(GO) vet $(PACKAGES)

$(ERRCHECK):
	$(GO) get -v github.com/kisielk/errcheck

$(GOLINT):
	$(GO) get -v github.com/golang/lint/golint

$(INTERFACER):
	$(GO) get -v github.com/mvdan/interfacer/cmd/interfacer

$(UNUSED):
	$(GO) get -v honnef.co/go/unused/cmd/unused

.PHONY: \
	all \
	ci \
	clean \
	errcheck \
	fmt \
	install \
	interfacer \
	lint \
	unused \
	vet
