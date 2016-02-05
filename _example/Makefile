export PATH := bin/:$(PATH)

ERRCHECK ?= bin/errcheck
GB ?= $(GOBIN)/gb
GO ?= go
GOLINT ?= bin/golint
OPERATOR ?= bin/operator
OPERATORC ?= bin/operatorc
OPERATORD ?= bin/operatord
PROTOC_GEN_GO ?= bin/protoc-gen-go
PROTOC_GEN_OPERATORCMD ?= bin/protoc-gen-operatorcmd
PROTOC_GEN_OPERATORD ?= bin/protoc-gen-operatord
PROTOC_GEN_OPERATORHUBOT ?= bin/protoc-gen-operatorhubot

all: build-operator $(OPERATOR) $(OPERATORD)

build-operator: $(OPERATORC) \
	$(PROTOC_GEN_GO) \
	$(PROTOC_GEN_OPERATORCMD) \
	$(PROTOC_GEN_OPERATORD) \
	$(PROTOC_GEN_OPERATORHUBOT)
	$< --cmd-out=src/cmd/operator \
		--hubot-out=hubot/scripts \
		--server-out=src/cmd/operatord src/

build: $(GB)
	$< build all

lint: $(GOLINT)
	@ for file in $$(find src -name '*.go'); do \
			$< $$file;
	  done

vet:
	$(GO) vet ./src/...

clean:
	rm -f $(ERRCHECK) \
		$(OPERATORC) \
		$(PROTOC_GEN_OPERATORCMD) \
		$(PROTOC_GEN_OPERATORD) \
		$(PROTOC_GEN_OPERATORHUBOT)

errcheck: $(ERRCHECK)
	$< ./src/...

$(ERRCHECK): $(GB)
	$< build github.com/kisielk/errcheck

$(GB):
	$(GO) get github.com/constabulary/gb/...

$(GOLINT): $(GB)
	$< build github.com/golang/lint/golint

$(OPERATOR): $(GB)
	$< build cmd/operator

$(OPERATORC): $(GB)
	$< build github.com/sr/operator/cmd/operatorc

$(OPERATORD): $(GB)
	$< build cmd/operatord

$(PROTOC_GEN_GO): $(GB)
	$< build github.com/golang/protobuf/protoc-gen-go

$(PROTOC_GEN_OPERATORCMD): $(GB)
	$< build github.com/sr/operator/cmd/protoc-gen-operatorcmd

$(PROTOC_GEN_OPERATORHUBOT): $(GB)
	$< build github.com/sr/operator/cmd/protoc-gen-operatorhubot

$(PROTOC_GEN_OPERATORD): $(GB)
	$< build github.com/sr/operator/cmd/protoc-gen-operatord

.PHONY: \
	all \
	build-operator \
	build \
	clean \
	lint \
	vet \
	errcheck
