DOCKER ?= docker
GO ?= go
GRPC_RUBY_PLUGIN ?= $(shell which grpc_ruby_plugin)

GOBIN ?= $(GOPATH)/bin
TMPDIR ?= /tmp

BREAD ?= $(GOPATH)/src/git.dev.pardot.com/Pardot/bread
BREAD_IMPORT_PATH ?= git.dev.pardot.com/Pardot/bread
BREAD_VENDOR_PATH ?= $(BREAD_IMPORT_PATH)/vendor
BREAD_VENDOR_DIR ?= $(BREAD)/vendor

PROTOC ?= $(shell which protoc)
PROTOC_GEN_GO ?= $(GOBIN)/protoc-gen-go
PROTOC_GEN_OPERATORCTL ?= $(GOBIN)/protoc-gen-operatorctl
PROTOC_GEN_OPERATORD ?= $(GOBIN)/protoc-gen-operatord
PROTOC_GEN_OPERATORLOCAL ?= $(GOBIN)/protoc-gen-operatorlocal
PROTOC_GEN_OPERATORLITAHELP ?= $(GOBIN)/protoc-gen-operatorlitahelp

SWAGGER ?= $(GOPATH)/bin/swagger

PROTO_DIR = $(BREAD)/pb

OPERATORD ?= $(GOBIN)/operatord
OPERATORD_LINUX ?= $(TMPDIR)/operatord_linux
OPERATORCTL ?= $(GOBIN)/operatorctl

OPERATOR_PKG ?= github.com/sr/operator
OPERATOR_DIR ?= $(BREAD)/vendor/github.com/sr/operator

OPERATORCTL_DIR ?= $(BREAD)/cmd/operatorctl
OPERATORD_DIR ?= $(BREAD)/cmd/operatord
SVC_DIR ?= $(BREAD)/pb
SVC_IMPORT_PATH ?= $(BREAD_IMPORT_PATH)/pb

CANOE ?= $(BREAD)/src/canoe
CANOE_PROTO ?= $(CANOE)/config/canoe.proto
CANOE_SWAGGER ?= $(CANOE)/config/canoe.swagger.json

generate: $(PROTOC) $(GRPC_RUBY_PLUGIN) $(PROTOC_GEN_GO) $(PROTOC_GEN_OPERATORCTL) $(PROTOC_GEN_OPERATORD) $(PROTOC_GEN_OPERATORLITAHELP) $(SWAGGER) $(CANOE_SWAGGER)
	$< \
		-I$(BREAD_VENDOR_DIR) \
		-I$(BREAD)/pb \
		--operatorctl_out=import_path=$(SVC_IMPORT_PATH):$(OPERATORCTL_DIR) \
		--operatord_out=import_path=$(SVC_IMPORT_PATH):$(OPERATORD_DIR) \
		--operatorlitahelp_out=import_path=$(SVC_IMPORT_PATH):src/hal9000/config \
		--go_out=plugins=grpc,import_path=$(SVC_IMPORT_PATH),Moperator.proto=$(OPERATOR_PKG),Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=github.com/golang/protobuf/ptypes/duration:$(SVC_DIR) \
		$(PROTO_DIR)/*.proto
	$< \
		-I$(BREAD_VENDOR_DIR) \
		-I$(BREAD)/pb \
		-I$(BREAD) \
		--ruby_out=src/hal9000/lib \
		--grpc_out=src/hal9000/lib \
		--plugin=protoc-gen-grpc=$(GRPC_RUBY_PLUGIN) \
		--go_out=plugins=grpc,import_path=$(SVC_IMPORT_PATH),Moperator.proto=$(OPERATOR_PKG),Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor,Mgoogle/protobuf/duration.proto=github.com/golang/protobuf/ptypes/duration:$(SVC_DIR) \
		$(BREAD)/pb/hal9000/*.proto
	echo "0a\n# rubocop:disable all\n.\nw" | ed src/hal9000/lib/hal9000/hal9000_services.rb >/dev/null
	echo "0a\n# rubocop:disable all\n.\nw" | ed src/hal9000/lib/hal9000/hal9000.rb >/dev/null
	$< \
		-I$(PROTO_DIR) \
		--ruby_out=src/changeling/lib \
		--plugin=protoc-gen-grpc=$(GRPC_RUBY_PLUGIN) \
		$(PROTO_DIR)/repository.proto
	$< \
		-I$(BREAD)/src/canoe/config \
		-I$(BREAD_VENDOR_DIR)/proto/googleapis \
		--ruby_out=$(CANOE)/lib \
		$(CANOE_PROTO)
	sed -i '' '/google\/api\/annotations/d' $(CANOE)/lib/canoe.rb
	echo "0a\n# rubocop:disable all\n.\nw" | ed $(CANOE)/lib/canoe.rb >/dev/null
	swagger generate client -f $(CANOE_SWAGGER) -t swagger

$(CANOE_SWAGGER): $(PROTOC) $(CANOE_PROTO)
	$< \
		-I$(BREAD)/src/canoe \
		-I$(BREAD_VENDOR_DIR)/googleapis \
		--swagger_out=logtostderr=true:$(CANOE) \
		$(word 2,$^)

ldap-dev: docker-build-ldap
	$(DOCKER) stop -t 3 operator_ldap >/dev/null || true
	$(DOCKER) rm operator_ldap >/dev/null || true
	$(DOCKER) run --name "operator_ldap" -P -d \
		-v "$(BREAD)/etc/ldap.ldif:/data/ldap.ldif" bread/ldap >/dev/null

test: etc/ldap.ldif ldap-dev
	export LDAP_PORT_389_TCP_PORT="$$(docker inspect -f '{{(index (index .NetworkSettings.Ports "389/tcp") 0).HostPort }}' operator_ldap)"; \
	export LDAP_PORT_389_TCP_ADDR="localhost"; \
	$(GO) test $$($(GO) list bread/... | grep -v bread/vendor) -ldap github.com/sr/operator/...

clean:
	rm -f etc/docker/ca-bundle.crt $(OPERATORD_LINUX) \
		$(OPERATORDCTL_DIR)/main-gen.go $(OPERATORD_DIR)/main-gen.go
	rm -f $(CANOE_SWAGGER)

build-operatord: $(TMPDIR)
	env CGO_ENABLED=0 GOOS=linux $(GO) build -a -tags netgo -ldflags "-w" \
		-o $(OPERATORD_LINUX) $(BREAD_IMPORT_PATH)/cmd/operatord

docker-build-ldap:
	docker build -f etc/docker/Dockerfile.ldap -t bread/ldap $(BREAD)

docker-build-operatord: etc/docker/ca-bundle.crt $(OPERATORD_LINUX)
	cp $(OPERATORD_LINUX) operatord
	$(DOCKER) build -f $(BREAD)/etc/docker/Dockerfile.operatord -t operatord_app $(BREAD)
	rm -f operatord

etc/docker/ca-bundle.crt:
	$(DOCKER) run docker.dev.pardot.com/base/centos:7 cat /etc/pki/tls/certs/ca-bundle.crt > $@

$(PROTOC_GEN_GO):
	$(GO) install -v $(BREAD_VENDOR_PATH)/github.com/golang/protobuf/protoc-gen-go

$(PROTOC_GEN_OPERATORCTL):
	$(GO) install -v $(BREAD_VENDOR_PATH)/github.com/sr/operator/cmd/protoc-gen-operatorctl

$(PROTOC_GEN_OPERATORD):
	$(GO) install -v $(BREAD_VENDOR_PATH)/github.com/sr/operator/cmd/protoc-gen-operatord

$(PROTOC_GEN_OPERATORLITAHELP):
	$(GO) install -v ./cmd/protoc-gen-operatorlitahelp

$(SWAGGER):
	$(GO) install -v $(BREAD_VENDOR_PATH)/github.com/go-swagger/go-swagger/cmd/swagger

.PHONY: \
	build-operatord \
	clean \
	docker-build-operatord \
	docker-build-ldap \
	generate \
	ldap-dev \
	test
