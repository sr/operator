ifndef VERSION
	VERSION = $(shell git rev-parse --short HEAD)
endif
GCLOUD_PROJECT_ID = dev-europe-west1
GCLOUD_CLUSTER = operator
GCLOUD_ZONE = europe-west1-d

-include etc/mk/golang.mk

hubot-dev: docker-build-hubot
	docker run --rm --name hubot --link operatord -it sr/hubot -a shell -l /

operatord-dev: docker-build-operatord
	docker run --rm -p 3000:3000 --name operatord \
		-e PAPERTRAIL_API_TOKEN=$(PAPERTRAIL_API_TOKEN) \
		-e BUILDKITE_API_TOKEN=$(BUILDKITE_API_TOKEN) \
		sr/operatord

proto: build install proto-grpc proto-cmd proto-hubot proto-operatord

proto-cmd:
	protoc --operatorcmd_out=src/cmd/operator -Isrc -I/usr/local/include src/services/**/*.proto
	@ gofmt -s -w src/cmd/operator

proto-hubot: src/hubot/proto/operator/ src/hubot/scripts/
	for file in $$(find src/services -name '*.proto' | grep -v src/hubot); do \
		cp $$file src/hubot/proto; \
	done
	cp src/operator/operator.proto src/hubot/proto/operator
	protoc --operatorhubot_out=src/hubot/scripts/ -Isrc src/services/**/*.proto

proto-operatord: proto-grpcinstrument
	protoc --operatord_out=src/cmd/operatord/ -Isrc src/services/**/*.proto
	@ gofmt -s -w src/cmd/operatord

proto-grpc: get-protoeasy
	protoeasy --go --grpc --go-import-path github.com/sr/operator/src --exclude hubot src/

proto-grpcinstrument: get-grpcinstrument
	protoc --grpcinstrument_out=src/ -Isrc src/services/**/*.proto

get-protoeasy:
	go get go.pedge.io/protoeasy/cmd/protoeasy
	go get github.com/golang/protobuf/protoc-gen-go/...

get-grpcinstrument:
	go get github.com/sr/grpcinstrument/...

src/hubot/proto/operator/:
	mkdir $@

src/hubot/scripts/:
	mkdir $@

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
	go build \
		-a \
		-installsuffix netgo \
		-tags netgo \
		-ldflags '-w -linkmode external -extldflags "-static"' \
		-o tmp/operatord \
		src/cmd/operatord/main-gen.go
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

gcloud-container-cluster:
	gcloud container \
		--project "$(GCLOUD_PROJECT_ID)" \
		clusters create "$(GCLOUD_CLUSTER)" \
			--zone "$(GCLOUD_ZONE)" \
			--num-nodes 3 \
			--machine-type "n1-standard-1" \
			--network "default" \
			--enable-cloud-logging \
			--scopes cloud-platform,compute-rw,logging-write,monitoring,storage-full,useraccounts-rw,userinfo-email

clean:
	go clean -i ./src/...
	rm -rf src/hubot/proto/{operator,services}
	rm -rf tmp/

.PHONY: \
	hubot-dev \
	operatord-dev \
	proto \
	proto-cmd \
	proto-hubot \
	proto-operatord \
	proto-grpc \
	proto-grpcinstrument \
	get-protoeasy \
	get-grpcinstrument \
	goget-openflights \
	docker-ci \
	docker-build-ci \
	docker-build-hubot \
	docker-build-operatord \
	docker-push-operatord \
	docker-push-hubot \
	docker-build-openflightsd \
	docker-push-openflightsd \
	gcloud-container-cluster \
	clean
