BREAD ?= $(GOPATH)
GO ?= $(shell which go)
GOBIN ?= $(GOPATH)/bin
TMPDIR ?= /tmp

CANOE ?= $(BREAD)/src/canoe
CANOE_PROTO ?= $(CANOE)/config/canoe.proto
CANOE_SWAGGER ?= $(CANOE)/config/canoe.swagger.json

PROTOC ?= $(shell which protoc)
SWAGGER = $(GOPATH)/bin/swagger

clean:
	rm -f $(CANOE_SWAGGER)

canoe: $(PROTOC) $(SWAGGER) $(CANOE_SWAGGER)
	$< \
		-I$(GOPATH)/src/canoe/config \
		-I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--ruby_out=$(CANOE)/lib \
		$(CANOE_PROTO)
	sed -i '' '/google\/api\/annotations/d' $(CANOE)/lib/canoe.rb
	echo "0a\n# rubocop:disable all\n.\nw" | ed $(CANOE)/lib/canoe.rb >/dev/null
	swagger generate client -f $(word 3,$^) -t src/bread/swagger

$(CANOE_SWAGGER): $(PROTOC) $(CANOE_PROTO)
	$< \
		-I$(GOPATH)/src/canoe \
		-I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--swagger_out=logtostderr=true:$(CANOE) \
		$(word 2,$^)

$(SWAGGER): $(GO)
	$< install github.com/go-swagger/go-swagger/cmd/swagger

.PHONY: \
	clean \
	canoe
