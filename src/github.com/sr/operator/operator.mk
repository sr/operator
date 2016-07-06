DOCKER ?= docker
GO ?= go
WATCHMAN_MAKE ?= watchman-make

GOBIN ?= $(GOPATH)/bin
OPERATORC ?= $(GOBIN)/operatorc
OPERATORCTL ?= $(GOBIN)/chatoopsctl
OPERATORD ?= $(GOBIN)/chatoopsd
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
PROTOC_GEN_OPERATORCTL ?= $(GOBIN)/protoc-gen-operatorctl
PROTOC_GEN_OPERATORD ?= $(GOBIN)/protoc-gen-operatord
PROTOC_GEN_OPERATORHUBOT ?= $(GOBIN)/protoc-gen-operatorhubot
PROTOC_GEN_OPERATORLOCAL ?= $(GOBIN)/protoc-gen-operatorlocal

OPERATORCTL_GEN_SRC ?= cmd/$(shell basename $(OPERATORCTL))/main-gen.go
OPERATORD_GEN_SRC ?= cmd/$(shell basename $(OPERATORD))/builder-gen.go
OPERATORHUBOT_GEN_SRC ?= $(shell find $(HUBOT_SCRIPTS_DIR) -type f -name "*-gen.js")

HUBOT_SCRIPTS_DIR ?= hubot/scripts
SVC_DIR ?= services
SVC_SRC ?= $(shell find $(SVC_DIR) -type f -name "*.proto" -o -name "*.go")

OPERATOR_IMPORT_PATH ?= github.com/sr/operator/chatoops/services

operator-generate: $(OPERATORC) $(PROTOC_GEN_GO) $(PROTOC_GEN_OPERATORCTL) $(PROTOC_GEN_OPERATORD) $(PROTOC_GEN_OPERATORHUBOT)
	$< \
		-import-path $(OPERATOR_IMPORT_PATH) \
		-cmd-out $(shell dirname $(OPERATORCTL_GEN_SRC)) \
		-server-out $(shell dirname $(OPERATORD_GEN_SRC)) \
		-hubot-out $(HUBOT_SCRIPTS_DIR) \
		$(SVC_DIR)

operator-clean:
	go clean -i ./...
	rm -f $(OPERATORCTL_GEN_SRC) $(OPERATORD_GEN_SRC) $(OPERATORHUBOT_GEN_SRC)

operator-dev: dev-run
	$(WATCHMAN_MAKE) -p '$(SVC_DIR)/**/*.go' '$(SVC_DIR)/**/*.proto' \
		'cmd/$$(basename $(OPERATORD))/*.go' -t dev-run

operator-dev-run: $(OPERATORD_GEN_SRC)
	pkill $$(basename $(OPERATORD)) || true
	$(GO) install -v ./$$(dirname $(OPERATORD_GEN_SRC))
	$$(basename $(OPERATORD)) &

$(OPERATORC): $(PROTOC_GEN_GO)
	$(GO) install -v github.com/sr/operator/cmd/operatorc

$(OPERATORCTL): $(OPERATORCTL_GEN_SRC)
	$(GO) install -v ./cmd/$$(basename $(OPERATORCTL))

$(OPERATORD): $(OPERATORD_SRC)
	$(GO) install -v ./cmd/$$(basename $(OPERATORD))

$(PROTOC_GEN_GO):
	$(GO) install -v github.com/golang/protobuf/protoc-gen-go

$(PROTOC_GEN_OPERATORCTL):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorctl

$(PROTOC_GEN_OPERATORD):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatord

$(PROTOC_GEN_OPERATORHUBOT):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorhubot

$(PROTOC_GEN_OPERATORLOCAL):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorlocal

.PHONY: \
	build \
	dev \
	dev-run \
	install \
	build-hubot \
	hubot-dev \
	docker-build-hubot \
	docker-build-operatorc
