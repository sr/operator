export PATH := bin/:$(PATH)
ifndef VERSION
	VERSION = $(shell git rev-parse --short HEAD)
endif
GCLOUD_PROJECT_ID = dev-europe-west1
GCLOUD_CLUSTER = operator
GCLOUD_ZONE = europe-west1-d
PROTOEASY = bin/protoeasy
OPERATORD = bin/operatord
OPERATOR = bin/operator
K8S_EXEC = bin/k8s-exec
PROTOC_GEN_GO = bin/protoc-gen-go
PROTOC_GEN_GRPCINSTRUMENT = bin/protoc-gen-grpcinstrument
PROTOC_GEN_OPERATORHUBOT = bin/protoc-gen-operatorhubot
PROTOC_GEN_OPERATORCMD = bin/protoc-gen-operatorcmd
PROTOC_GEN_OPERATORD = bin/protoc-gen-operatord

-include etc/mk/golang.mk

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

clean:
	rm -f src/cmd/**/*-gen.go \
		src/hubot/scripts/*-gen.coffee \
		$(OPERATOR) \
		$(OPERATORD) \
		$(K8S_EXEC) \
		$(PROTOEASY) \
		$(PROTOC_GEN_GO) \
		$(PROTOC_GEN_GRPCINSTRUMENT) \
		$(PROTOC_GEN_OPERATORCMD) \
		$(PROTOC_GEN_OPERATORD) \
		$(PROTOC_GEN_OPERATORHUBOT) \
	rm -rf tmp/

$(OPERATOR): $(GB) proto-cmd
	$< build cmd/operator

$(OPERATORD): $(GB) proto-operatord
	$< build cmd/operatord

$(K8S_EXEC): $(GB)
	$< build cmd/k8s-exec

$(PROTOEASY): $(GB) $(PROTOC_GEN_GO)
	$< build go.pedge.io/protoeasy/cmd/protoeasy

$(PROTOC_GEN_GO): $(GB)
	$< build github.com/golang/protobuf/protoc-gen-go

$(PROTOC_GEN_GRPCINSTRUMENT): $(GB)
	$< build github.com/sr/grpcinstrument/cmd/protoc-gen-grpcinstrument

$(PROTOC_GEN_OPERATORCMD): $(GB)
	$< build cmd/protoc-gen-operatorcmd

$(PROTOC_GEN_OPERATORD): $(GB)
	$< build cmd/protoc-gen-operatord

$(PROTOC_GEN_OPERATORHUBOT): $(GB)
	$< build cmd/protoc-gen-operatorhubot

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
