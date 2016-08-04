GO ?= go
GOBIN ?= $(GOPATH)/bin
GOFMT ?= $(shell which gofmt)
GOLINT ?= $(GOBIN)/golint
DEADLEAVES ?= $(GOBIN)/deadleaves
ERRCHECK = $(GOBIN)/errcheck
INTERFACER = $(GOBIN)/interfacer
UNUSED = $(GOBIN)/unused

PACKAGES = $(shell $(GO) list bread/... chatops/... privet/... devenv/... github.com/sr/operator/...)
TOOLS = $(shell $(GO) list golang.org/x/tools/cmd/...)

OPERATOR_IMPORT_PATH ?= bread
OPERATORD ?= $(GOPATH)/bin/operatord
OPERATORCTL ?= $(GOPATH)/bin/operatorctl
OPERATORCTL_GEN_SRC ?= $(GOPATH)/src/bread/cmd/operatorctl/main-gen.go
OPERATORD_GEN_SRC ?= $(GOPATH)/src/bread/cmd/operatord/builder-gen.go
SVC_DIR ?= $(GOPATH)/src/bread
HUBOT_SCRIPTS_DIR ?= $(GOPATH)/src/chatops/hubot/scripts

include $(GOPATH)/src/github.com/sr/operator/operator.mk

all: deadleaves fmt lint vet test install errcheck interfacer unused

generate: operator-generate

install:
	$(GO) install -v $$($(GO) list ./... | grep -v github.com/hashicorp/terraform)

test:
	$(GO) test -race $(PACKAGES)

clean: operator-clean
	$(GO) clean -i ./...

install-tools:
	$(GO) install -v $(TOOLS)

deadleaves: $(DEADLEAVES)
	@ out="$$($< 2>&1 | grep -v github.com/hashicorp/terraform)"; \
		if [ -n "$$out" ]; then \
			echo "$$out"; \
			exit 1; \
		fi

fmt: $(GOFMT)
	@ for file in $$(find src -name '*.go' | grep -v -E '\.pb\.go$$'); do \
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
			out="$$($< $$pkg | grep -v -E 'main-gen\.go')"; \
			if [ -n "$$out" ]; then \
				echo "$$out"; \
				fail=true; \
			fi; \
	  done; \
	  test $$fail && exit 1; true

interfacer: $(INTERFACER)
	$< $(PACKAGES)

$(DEADLEAVES):
	$(GO) install -v github.com/nf/deadleaves

$(ERRCHECK):
	$(GO) install -v github.com/kisielk/errcheck

$(GOLINT):
	$(GO) install -v github.com/golang/lint/golint

$(INTERFACER):
	$(GO) install -v github.com/mvdan/interfacer/cmd/interfacer

$(UNUSED):
	$(GO) install -v github.com/dominikh/go-unused/cmd

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
