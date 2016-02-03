export PATH := bin/:$(PATH)
export GO15VENDOREXPERIMENT := 1
VERSION ?= $(shell git rev-parse --short HEAD)
GO ?= go
ERRCHECK = $(GOBIN)/errcheck
GOLINT ?= $(GOBIN)/golint

-include etc/mk/golang.mk

build:
	$(GO) build -v ./...

install:
	$(GO) install -v ./...

lint: $(GOLINT)
	@ for file in $$(find . -name '*.go' | grep -v _example | grep -v vendor); do \
			$< $$file; \
	  done

vet:
	$(GO) vet ./...

errcheck: $(ERRCHECK)
	$< ./...

clean:
	$(GO) clean -i ./..

$(ERRCHECK):
	$(GO) get -v github.com/kisielk/errcheck

$(GOLINT):
	$(GO) get -v github.com/golang/lint/golint

.PHONY: \
	build \
	install \
	lint \
	vet \
	errcheck

hubot-dev:
	@ touch $(shell pwd)/tmp/.hubot_history
	docker run --rm --name hubot -it --net=host \
		-v $(shell pwd)/src/hubot/scripts:/hubot/scripts \
		-v $(shell pwd)/tmp/.hubot_history:/hubot/.hubot_history \
		-e OPERATORD_ADDRESS=localhost:3000 \
		sr/hubot -d -a shell -l /

operatord-dev: $(OPERATORD)
	$<

proto: build proto-grpc proto-cmd proto-hubot proto-operatord

example-vendor:
	rm -rf _example/vendor/src/github.com/sr/operator
	for file in $$(gvt list -f "{{.Importpath}}"); do \
		rm -rf _example/vendor/src/$$file; \
	done
	cp -r vendor/* _example/vendor/src/
	mkdir -p  _example/vendor/src/github.com/sr/operator
	cp -r *.go cmd proto  _example/vendor/src/github.com/sr/operator
	git add -A _example/vendor/src _example/vendor/src/github.com/sr/operator
	git add -u _example/vendor/src _example/vendor/src/github.com/sr/operator

proto-cmd: $(PROTOC_GEN_OPERATORCMD)
	protoc --operatorcmd_out=src/cmd/operator -Isrc -I/usr/local/include src/services/**/*.proto
	@ gofmt -s -w src/cmd/operator

proto-hubot: $(PROTOC_GEN_OPERATORHUBOT)
	rm -rf src/hubot/proto src/hubot/scripts
	cp -r vendor/proto src/hubot
	mkdir src/hubot/proto/operator src/hubot/scripts
	for file in $$(find src/services -name '*.proto'); do \
		cp $$file src/hubot/proto; \
	done
	cp src/operator/operator.proto src/hubot/proto/operator/
	protoc --operatorhubot_out=src/hubot/scripts/ -Isrc src/services/**/*.proto

proto-operatord: $(PROTOC_GEN_OPERATORD) proto-grpcinstrument
	protoc --operatord_out=src/cmd/operatord/ -Isrc src/services/**/*.proto
	@ gofmt -s -w src/cmd/operatord

proto-protoeasy: $(PROTOEASY)
	go get -v go.pedge.io/pkg/cmd/strip-package-comments
	cd vendor/src/go.pedge.io/protoeasy && $(shell pwd)/$< && \
		find . -name *\.pb\*\.go | \
		grep -v vendor | \
		xargs strip-package-comments

proto-grpc: $(PROTOEASY)
	$< --go --grpc --exclude hubot src/

proto-grpcinstrument: $(PROTOC_GEN_GRPCINSTRUMENT)
	protoc --grpcinstrument_out=src/ -Isrc src/services/**/*.proto

goget-openflights:
	go get go.pedge.io/openflights

docker-ci: docker-build-ci
	docker run --rm -e GITHUB_REPO_TOKEN=$(GITHUB_REPO_TOKEN) sr/ci bin/ci

docker-build-ci:
	docker build -t sr/ci -f etc/docker/Dockerfile.ci .

docker-build-hubot:
	docker build -t sr/hubot -f etc/docker/Dockerfile.hubot .

docker-build-operatord:
	rm -rf tmp
	mkdir -p tmp
	GOPATH=$(shell pwd)/vendor:$(shell pwd) CGO_ENABLED=0 GOOS=linux \
	go build -installsuffix cgo -ldflags '-w -extld ld -extldflags -static' \
		-o tmp/operatord src/cmd/operatord/main-gen.go && \
	go build -installsuffix cgo -ldflags '-w -extld ld -extldflags -static' \
		-o tmp/k8s-exec src/cmd/k8s-exec/main.go
	docker build -t sr/operatord -f etc/docker/Dockerfile.operatord .

docker-push-operatord:
	docker tag sr/operatord gcr.io/$(GCLOUD_PROJECT_ID)/operatord:$(VERSION)
	gcloud docker push gcr.io/$(GCLOUD_PROJECT_ID)/operatord

docker-push-hubot: docker-build-hubot
	docker tag sr/hubot gcr.io/$(GCLOUD_PROJECT_ID)/hubot:$(VERSION)
	gcloud docker push gcr.io/$(GCLOUD_PROJECT_ID)/hubot

docker-build-openflightsd: goget-openflights
	make -C $(GOPATH)/src/go.pedge.io/openflights -f Makefile docker-build-openflightsd

docker-push-openflightsd:
	docker tag pedge/openflightsd gcr.io/operator-europe-west/openflightsd:$(VERSION)
	gcloud docker push gcr.io/operator-europe-west/openflightsd

.PHONY: \
	hubot-dev \
	operatord-dev \
	proto \
	proto-cmd \
	proto-hubot \
	proto-operatord \
	proto-grpc \
	proto-grpcinstrument \
	goget-openflights \
	docker-ci \
	docker-build-ci \
	docker-build-hubot \
	docker-build-operatord \
	docker-push-operatord \
	docker-push-hubot \
	docker-build-openflightsd \
	docker-push-openflightsd \
	clean
