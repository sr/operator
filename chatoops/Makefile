GO ?= go
GOBIN ?= $(GOPATH)/bin
OPERATORC ?= $(GOBIN)/operatorc
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
DOCKER ?= docker

OPERATOR ?= $(GOBIN)/operator
OPERATORD ?= $(GOBIN)/operatord
OPERATOR_SRC ?= cmd/operator/main-gen.go
OPERATORD_SRC ?= $(shell find cmd/operatord -type f -name "*.go")

OPERATORD_ADDRESS ?= localhost:3000
export OPERATORD_ADDRESS

IMPORTPATH ?= github.com/sr/operator/chatoops

build: $(OPERATORC) $(PROTOC_GEN_GO)
	$< \
		--import-path $(IMPORTPATH)/services \
		--cmd-out cmd/operator \
		--hubot-out hubot/scripts \
		--server-out cmd/operatord \
		services

docker-build:
	$(DOCKER) run --rm  \
		-v $(shell pwd):/in \
		-v $(shell pwd):/out \
		srozet/operatorc:3b62142 \
			--import-path $(IMPORTPATH)/services \
			--cmd-out /out/cmd/operator \
			--hubot-out /out/hubot/scripts \
			--server-out /out/cmd/operatord \
			/in/services

operator: $(OPERATOR)

operatord-dev: $(OPERATORD)
	$<

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

$(OPERATOR): $(OPERATOR_SRC)
	$(GO) install -v github.com/sr/operator/chatoops/cmd/operator

$(OPERATORD): $(OPERATORD_SRC)
	$(GO) install -v github.com/sr/operator/chatoops/cmd/operatord/...

$(OPERATORC): $(PROTOC_GEN_GO)
	$(GO) install -v github.com/sr/operator/cmd/...

$(PROTOC_GEN_GO):
	$(GO) install -v vendor/github.com/golang/protobuf/protoc-gen-go

.PHONY: \
	build \
	operatord \
	hubot-dev \
	docker-build-hubot \
	docker-build-operatorc
