DOCKER ?= docker
GO ?= go
WATCHMAN ?= watchman

GOBIN ?= $(GOPATH)/bin
OPERATORC ?= $(GOBIN)/operatorc
OPERATORCTL ?= $(GOBIN)/chatoopsctl
OPERATORD ?= $(GOBIN)/chatoopsd
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
PROTOC_GEN_OPERATORCTL ?= $(GOBIN)/protoc-gen-operatorctl
PROTOC_GEN_OPERATORD ?= $(GOBIN)/protoc-gen-operatord
PROTOC_GEN_OPERATORHUBOT ?= $(GOBIN)/protoc-gen-operatorhubot
PROTOC_GEN_OPERATORLOCAL ?= $(GOBIN)/protoc-gen-operatorlocal

OPERATORD_GEN_SRC ?= cmd/chatoopsd/services-gen.go
OPERATORCTL_GEN_SRC ?= cmd/chatoopsctl/main-gen.go
OPERATORHUBOT_GEN_DIR ?= hubot/scripts

SVC_DIR ?= services
SVC_SRC ?= $(shell find $(SVC_DIR) -type f -name "*.proto" -o -name "*.go" | sort)

IMPORTPATH ?= github.com/sr/operator/chatoops/$(SVC_DIR)

dev: dev-run
	watchman-make -p 'services/**/*.go' 'services/**/*.proto' \
		'cmd/chatoopsd/main.go' -t dev-run

dev-run: $(OPERATORD_GEN_SRC)
	pkill chatoopsd || true
	$(GO) install -v ./$$(dirname $(OPERATORD_GEN_SRC))
	chatoopsd &

install: $(OPERATORCTL_GEN_SRC) $(OPERATORD_GEN_SRC)
	$(GO) install -v ./$$(dirname $(OPERATORCTL_GEN_SRC)) \
		./$$(dirname $(OPERATORD_GEN_SRC))

build-hubot: $(SVC_SRC) $(OPERATORC) $(PROTOC_GEN_OPERATORHUBOT)
	$(OPERATORC) --import-path $(IMPORTPATH) \
		--hubot-out $(OPERATORHUBOT_GEN_DIR) $(SVC_DIR)

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

$(OPERATORCTL): $(OPERATORCTL_SRC)
	$(GO) install -v ./cmd/operatorctl

$(OPERATORCTL_GEN_SRC): $(OPERATORC) $(SVC_SRC) $(PROTOC_GEN_OPERATORCTL)
	$(OPERATORC) --import-path $(IMPORTPATH) \
		--cmd-out $(shell dirname $(OPERATORCTL_GEN_SRC)) $(SVC_DIR)

$(OPERATORD): $(OPERATORD_SRC)
	$(GO) install -v ./cmd/operatord

$(OPERATORD_GEN_SRC): $(OPERATORC) $(SVC_SRC) $(PROTOC_GEN_OPERATORD)
	$(OPERATORC) --import-path $(IMPORTPATH) \
		--server-out $(shell dirname $(OPERATORD_GEN_SRC)) $(SVC_DIR)

$(PROTOC_GEN_OPERATORCTL):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorctl

$(PROTOC_GEN_OPERATORD):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatord

$(PROTOC_GEN_OPERATORHUBOT):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorhubot

$(PROTOC_GEN_OPERATORLOCAL):
	$(GO) install -v github.com/sr/operator/cmd/protoc-gen-operatorlocal

$(PROTOC_GEN_GO):
	$(GO) install -v vendor/github.com/golang/protobuf/protoc-gen-go

.PHONY: \
	dev \
	dev-run \
	install \
	build-hubot \
	hubot-dev \
	docker-build-hubot \
	docker-build-operatorc
