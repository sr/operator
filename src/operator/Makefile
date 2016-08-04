GO ?= go
GOBIN ?= $(GOPATH)/bin
TMPDIR ?= /tmp

OPERATOR_DIR ?= $(GOPATH)/src/github.com/sr/operator
OPERATOR_PROTO ?= $(OPERATOR_DIR)/operator.proto
OPERATOR_IMPORT_PATH ?= bread
OPERATORD ?= $(GOPATH)/bin/operatord
OPERATORD_LINUX ?= $(TMPDIR)/operatord
OPERATORCTL ?= $(GOPATH)/bin/operatorctl
OPERATORCTL_GEN_SRC ?= $(GOPATH)/src/bread/cmd/operatorctl/main-gen.go
OPERATORD_GEN_SRC ?= $(GOPATH)/src/bread/cmd/operatord/builder-gen.go

HUBOT_SCRIPTS_DIR ?= $(GOPATH)/src/operator/hubot/scripts
HUBOT_PROTO_DIR ?= $(GOPATH)/src/operator/hubot/proto

SVC_DIR ?= $(GOPATH)/src/bread
SVC_PROTOS ?= $(shell find $(SVC_DIR) -name '*.proto')

-include $(GOPATH)/src/github.com/sr/operator/operator.mk

build-operatord-linux: $(TMPDIR)
	env CGO_ENABLED=0 GOOS=linux \
		$(GO) build -a -tags netgo -ldflags '-w' \
			-o $(TMPDIR)/operatord_linux bread/cmd/operatord

generate: operator-generate
	cp $(SVC_PROTOS) $(OPERATOR_PROTO) $(HUBOT_PROTO_DIR)

clean: operator-clean
	rm -f \
		$(HUBOT_PROTO_DIR)/*.proto \
		$(HUBOT_SCRIPTS_DIR)/*-gen.js \
		$(OPERATORD_LINUX)

docker-build-operatord:
	docker build -f Dockerfile.operatord -t operatord_app .

docker-build-hubot:
	docker build -f Dockerfile.hubot -t operatorhubot_app .

.PHONY: \
	build-operatord \
	generate \
	clean \
	docker-build-hubot
