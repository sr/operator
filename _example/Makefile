export PATH := bin/:$(PATH)

ERRCHECK = bin/errcheck
GB = $(GOBIN)/gb
GOLINT = bin/golint
OPERATORC = bin/operatorc
PROTOC_GEN_GO = bin/protoc-gen-go
PROTOC_GEN_OPERATORHUBOT = bin/protoc-gen-operatorhubot

build-operator: $(OPERATORC) $(PROTOC_GEN_GO) $(PROTOC_GEN_OPERATORHUBOT)
	$< --hubot-out=hubot/scripts src/

build: $(GB)
	$< build all

lint: $(GOLINT)
	@ for file in $$(find src -name '*.go'); do \
			$< $$file;
	  done

vet:
	go vet ./src/...

clean:
	rm -f $(ERRCHECK) \
		$(GB) \
		$(GOLINT) \
		$(OPERATORC) \
		$(PROTOC_GEN_GO) \
		$(PROTOC_GEN_OPERATORHUBOT)

errcheck: $(ERRCHECK)
	$< ./src/...

$(ERRCHECK): $(GB)
	$< build github.com/kisielk/errcheck

$(GB):
	go get github.com/constabulary/gb/...

$(GOLINT): $(GB)
	$< build github.com/golang/lint/golint

$(PROTOC_GEN_GO): $(GB)
	$< build github.com/golang/protobuf/protoc-gen-go

$(PROTOC_GEN_OPERATORHUBOT): $(GB)
	$< build github.com/sr/operator/cmd/protoc-gen-operatorhubot

.PHONY: \
	build \
	lint \
	vet \
	errcheck
