VERSION = $(shell git rev-parse --short HEAD)

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

docker-push-openflightsd: # docker-build-openflightsd
	docker tag pedge/openflightsd gcr.io/operator-europe-west/openflightsd:$(VERSION)
	gcloud docker push gcr.io/operator-europe-west/openflightsd

.PHONY: \
	proto \
	proto-get \
	goget-openflights \
	docker-build-openflightsd \
	docker-push-openflightsd
