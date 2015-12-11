VERSION = $(shell git rev-parse --short HEAD)
GCLOUD_CLUSTER = operator-1
GCLOUD_ZONE = europe-west1-d

deps:
	go get -d -v ./src/...

updatedeps:
	go get -d -v -u -f ./src/...

testdeps:
	go get -d -v -t ./src/...

updatetestdeps:
	go get -d -v -t -u -f ./src/...

build: deps
	go build ./src/...

install: deps
	go install ./src/...

lint: testdeps
	go get -v github.com/golang/lint/golint
	for file in $$(find . -name '*.go' | grep -v '\.pb\.go' | grep -v '\.pb\.gw\.go'); do \
		golint $${file}; \
		if [ -n "$$(golint $${file})" ]; then \
			exit 1; \
		fi; \
	done

vet: testdeps
	go vet ./src/...

errcheck: testdeps
	go get -v github.com/kisielk/errcheck
	errcheck ./src/...

pretest: lint

test: testdeps pretest
	go test ./src/...

clean:
	go clean -i ./src/...

proto-get:
	go get -u github.com/golang/protobuf/proto/... \
		github.com/golang/protobuf/protoc-gen-go/... \
		go.pedge.io/google-protobuf/... \
		go.pedge.io/googleapis/... \
		go.pedge.io/protolog/cmd/protoc-gen-protolog/... \
		go.pedge.io/protolog/cmd/protoc-gen-protolog \
		go.pedge.io/tools/protoc-all \
		github.com/gengo/grpc-gateway/protoc-gen-grpc-gateway/... \
		google.golang.org/grpc

proto: proto-grpcmd proto-hubot

proto-grpc:
	@ PROTOC_INCLUDE_PATH=src protoc-all github.com/sr/operator

proto-hubot:
	@	for file in $$(find src/services -name '*.proto' | grep -v src/hubot); do \
			cp $$file src/hubot/proto; \
		done; \
		mkdir src/hubot/proto/operator; \
		cp src/operator/operator.proto src/hubot/proto/operator; \
		protoc --hubot_out=src/hubot/scripts/ -Isrc src/services/**/*.proto

proto-grpcmd:
	@ protoc --grpcmd_out=src/cmd/ -Isrc src/services/gcloud/*.proto
	@ protoc --grpcmd_out=src/cmd/ -Isrc src/services/papertrail/*.proto

goget-openflights:
	go get go.pedge.io/openflights

docker-build-hubot:
	docker build -t sr/hubot -f etc/docker/Dockerfile.hubot .

docker-push-hubot: docker-build-hubot
	docker tag sr/hubot gcr.io/operator-europe-west/hubot:$(VERSION)
	gcloud docker push gcr.io/operator-europe-west/hubot

docker-build-openflightsd: goget-openflights
	make -C $(GOPATH)/src/go.pedge.io/openflights -f Makefile docker-build-openflightsd

docker-push-openflightsd:
	docker tag pedge/openflightsd gcr.io/operator-europe-west/openflightsd:$(VERSION)
	gcloud docker push gcr.io/operator-europe-west/openflightsd

gcloud-container-cluster:
	gcloud container \
		--project "operator-europe-west" \
		clusters create "$(GCLOUD_CLUSTER)" \
			--zone "$(GCLOUD_ZONE)" \
			--num-nodes 3 \
			--machine-type "n1-standard-1" \
			--network "default" \
			--enable-cloud-logging \
			--scopes cloud-platform,compute-rw,logging-write,monitoring,storage-full,useraccounts-rw,userinfo-email

.PHONY: \
	deps \
	updatedeps \
	testdeps \
	updatetestdeps \
	build \
	install \
	lint \
	vet \
	errcheck \
	pretest \
	test \
	clean \
	proto \
	proto-hubot \
	proto-grpcmd \
	proto-get \
	goget-openflights \
	docker-build-hubot \
	docker-push-hubot \
	docker-build-openflightsd \
	docker-push-openflightsd \
	gcloud-container-cluster
