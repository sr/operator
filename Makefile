VERSION = $(shell git rev-parse --short HEAD)
GCLOUD_CLUSTER = operator-1
GCLOUD_ZONE = europe-west1-d

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

proto:
	PROTOC_INCLUDE_PATH=src protoc-all github.com/sr/operator

goget-openflights:
	go get go.pedge.io/openflights

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
	proto \
	proto-get \
	goget-openflights \
	docker-build-openflightsd \
	docker-push-openflightsd
