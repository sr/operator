VERSION = $(shell git rev-parse --short HEAD)
GCLOUD_PROJECT_ID = dev-europe-west1
GCLOUD_CLUSTER = operator
GCLOUD_ZONE = europe-west1-d

-include etc/mk/golang.mk

hubot-dev: docker-build-hubot
	docker run --rm --name hubot --link operatord -it sr/hubot -a shell -l /

operatord-dev: docker-build-operatord
	docker run --rm -p 3000:3000 --name operatord \
		-v /etc/ssl/certs:/etc/ssl/certs \
		-e PAPERTRAIL_API_TOKEN=$(PAPERTRAIL_API_TOKEN) \
		-e BUILDKITE_API_TOKEN=$(BUILDKITE_API_TOKEN) \
		sr/operatord

clean:
	go clean -i ./src/...
	rm -rf src/hubot/proto/{operator,services}
	rm -rf tmp/

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

proto: build install proto-grpc proto-grpcmd proto-hubot proto-operatord

proto-grpc:
	PROTOC_INCLUDE_PATH=src/ protoc-all github.com/sr/operator && \
		find src/hubot -name '*.pb.go' | xargs rm -f

src/hubot/proto/operator/:
	mkdir $@

src/hubot/scripts/:
	mkdir $@

proto-hubot: src/hubot/proto/operator/ src/hubot/scripts/
	for file in $$(find src/services -name '*.proto' | grep -v src/hubot); do \
		cp $$file src/hubot/proto; \
	done
	cp src/operator/operator.proto src/hubot/proto/operator
	protoc --hubot_out=src/hubot/scripts/ -Isrc src/services/**/*.proto

proto-grpcmd:
	protoc --grpcmd_out=src/cmd/ -Isrc src/services/gcloud/*.proto
	protoc --grpcmd_out=src/cmd/ -Isrc src/services/papertrail/*.proto
	protoc --grpcmd_out=src/cmd/ -Isrc src/services/buildkite/*.proto

proto-operatord:
	protoc --operatord_out=src/cmd/operatord/ -Isrc src/services/**/*.proto

goget-openflights:
	go get go.pedge.io/openflights

docker-ci: docker-build-ci
	docker run --rm -e GITHUB_REPO_TOKEN=$(GITHUB_REPO_TOKEN) sr/ci bin/ci

docker-build-ci:
	docker build -t sr/ci -f etc/docker/Dockerfile.ci .

docker-build-hubot: proto-hubot
	docker build -t sr/hubot -f etc/docker/Dockerfile.hubot .

docker-build-operatord: proto-grpc proto-operatord
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

docker-push-operatord: docker-build-operatord
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
