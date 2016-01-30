export PATH := bin/:$(PATH)

ERRCHECK = bin/errcheck
GB = $(GOBIN)/gb
GBVENDOR = bin/gb-vendor
GOLINT = bin/golint
OPERATORC = bin/operatorc
PROTOC_GEN_GO = bin/protoc-gen-go
PROTOEASY = bin/protoeasy

build-operator: $(OPERATORC)
	$< --hubot-out=hubot/scripts/ src/

proto-golang: $(PROTOC_GEN_GO)
	for file in $$(find src/services -name *.proto); do \
		protoc --go_out=plugins=grpc,Moperator.proto=github.com/sr/operator/proto:src/ \
			-Isrc/ \
			-Ivendor/src/github.com/sr/operator/proto \
			$$file; \
	done

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
		$(GBVENDOR) \
		$(GOLINT) \
		$(OPERATORC) \
		$(PROTOC_GEN_GO) \
		$(PROTOEASY)

errcheck: $(ERRCHECK)
	$< ./src/...

$(ERRCHECK): $(GB)
	$< build github.com/kisielk/errcheck

$(GB):
	go get github.com/constabulary/gb/...

$(GBVENDOR): $(GB)
	$< build github.com/constabulary/gb/cmd/gb-vendor

$(GOLINT): $(GB)
	$< build github.com/golang/lint/golint

$(PROTOC_GEN_GO): $(GB)
	$< build github.com/golang/protobuf/protoc-gen-go

$(PROTOEASY): $(GB)
	$< build go.pedge.io/protoeasy/cmd/protoeasy

$(OPERATORC): $(GB)
	$< build github.com/sr/operator/cmd/operatorc

.PHONY: \
	build \
	lint \
	vet \
	errcheck \
