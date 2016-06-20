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

IMPORTPATH ?= github.com/sr/operator/chatoops/services

build: $(OPERATORD_GEN_SRC) $(OPERATORCTL_GEN_SRC) build-hubot

clean:
	go clean -i ./...
	rm -f $(OPERATORCTL_GEN_SRC) $(OPERATORD_GEN_SRC) $(OPERATORHUBOT_GEN_SRC)

dev: dev-run
	$(WATCHMAN_MAKE) -p '$(SVC_DIR)/**/*.go' '$(SVC_DIR)/**/*.proto' \
		'cmd/$$(basename $(OPERATORD))/*.go' -t dev-run

dev-run: $(OPERATORD_GEN_SRC)
	pkill $$(basename $(OPERATORD)) || true
	$(GO) install -v ./$$(dirname $(OPERATORD_GEN_SRC))
	$$(basename $(OPERATORD)) &

install: $(OPERATORCTL_GEN_SRC) $(OPERATORD_GEN_SRC)
	$(GO) install -v ./$$(dirname $(OPERATORCTL_GEN_SRC)) \
		./$$(dirname $(OPERATORD_GEN_SRC))

build-hubot: $(SVC_SRC) $(OPERATORC) $(PROTOC_GEN_OPERATORHUBOT)
	$(OPERATORC) --import-path $(IMPORTPATH) \
		--hubot-out $(HUBOT_SCRIPTS_DIR) $(SVC_DIR)

hubot-dev: docker-build-hubot
	@ touch .hubot_history
	cp ../operator.proto services/**/*.proto hubot/proto/
	$(DOCKER) run --rm --name chatoops-hubot -it --net=host \
		-v $(shell pwd)/hubot/proto:/hubot/proto:ro \
		-v $(shell pwd)/hubot/scripts:/hubot/scripts:ro \
		-v $(shell pwd)/.hubot_history:/hubot/.hubot_history \
		-e OPERATORD_ADDRESS=$(OPERATORD_ADDRESS) \
		chatoops/hubot -d -a shell -l /

docker-build-hubot: etc/docker/Dockerfile.hubot
	$(DOCKER) build -f $< -t chatoops/hubot .

docker-build-operatorc: etc/docker/Dockerfile.operatorc
	$(DOCKER) build -f $< -t chatoops/operatorc .

$(OPERATORC): $(PROTOC_GEN_GO)
	$(GO) install -v github.com/sr/operator/cmd/operatorc

$(OPERATORCTL): $(OPERATORCTL_GEN_SRC)
	$(GO) install -v ./cmd/$$(basename $(OPERATORCTL))

$(OPERATORD): $(OPERATORD_SRC)
	$(GO) install -v ./cmd/$$(basename $(OPERATORD))

$(OPERATORCTL_GEN_SRC): $(OPERATORC) $(SVC_SRC) $(PROTOC_GEN_OPERATORCTL)
	$(OPERATORC) --import-path $(IMPORTPATH) \
		--cmd-out $(shell dirname $(OPERATORCTL_GEN_SRC)) $(SVC_DIR)

$(OPERATORD_GEN_SRC): $(OPERATORC) $(SVC_SRC) $(PROTOC_GEN_OPERATORD)
	$(OPERATORC) --import-path $(IMPORTPATH) \
		--server-out $(shell dirname $(OPERATORD_GEN_SRC)) $(SVC_DIR)

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
