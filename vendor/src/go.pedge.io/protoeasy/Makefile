PKGS := $(shell go list ./... | grep -v 'go.pedge.io/protoeasy/vendor')

EXTRA_PKGS := \
	github.com/gengo/grpc-gateway/protoc-gen-grpc-gateway/... \
	github.com/golang/protobuf/protoc-gen-go/... \
	github.com/gogo/protobuf/protoc-gen-gofast/... \
	github.com/gogo/protobuf/protoc-gen-gogo/... \
	github.com/gogo/protobuf/protoc-gen-gogofast/... \
	github.com/gogo/protobuf/protoc-gen-gogofaster/... \
	github.com/gogo/protobuf/protoc-gen-gogoslick/... \
	github.com/gengo/grpc-gateway/runtime/... \
	go.pedge.io/googleapis/google/datastore/v1beta3/... \
	go.pedge.io/googleapis/google/devtools/cloudtrace/v1/... \
	go.pedge.io/googleapis/google/example/library/v1/... \
	go.pedge.io/googleapis/google/iam/v1/... \
	go.pedge.io/googleapis/google/longrunning/... \
	go.pedge.io/googleapis/google/pubsub/v1/... \
	go.pedge.io/googleapis/google/pubsub/v1beta2/... \
	go.pedge.io/googleapis/google/rpc/... \
	go.pedge.io/googleapis/google/type/...

EXTRA_CMDS := \
	go.pedge.io/protoeasy/vendor/github.com/gengo/grpc-gateway/protoc-gen-grpc-gateway \
	go.pedge.io/protoeasy/vendor/github.com/golang/protobuf/protoc-gen-go \
	go.pedge.io/protoeasy/vendor/github.com/gogo/protobuf/protoc-gen-gofast \
	go.pedge.io/protoeasy/vendor/github.com/gogo/protobuf/protoc-gen-gogo \
	go.pedge.io/protoeasy/vendor/github.com/gogo/protobuf/protoc-gen-gogofast \
	go.pedge.io/protoeasy/vendor/github.com/gogo/protobuf/protoc-gen-gogofaster \
	go.pedge.io/protoeasy/vendor/github.com/gogo/protobuf/protoc-gen-gogoslick

export GO15VENDOREXPERIMENT=1

all: integration docker-integration

deps:
	GO15VENDOREXPERIMENT=0 go get -d -v $(PKGS) $(EXTRA_PKGS)

updatedeps:
	GO15VENDOREXPERIMENT=0 go get -d -v -u -f $(PKGS) $(EXTRA_PKGS)

testdeps:
	GO15VENDOREXPERIMENT=0 go get -d -v -t $(PKGS) $(EXTRA_PKGS)

updatetestdeps:
	GO15VENDOREXPERIMENT=0 go get -d -v -t -u -f $(PKGS) $(EXTRA_PKGS)

vendorupdate:
	GO15VENDOREXPERIMENT=0 GOOS=linux GOARCH=amd64 go get -d -v -t -u -f $(PKGS) $(EXTRA_PKGS)

vendornoupdate:
	go get -v github.com/kardianos/govendor
	rm -rf vendor
	govendor init
	GOOS=linux GOARCH=amd64 govendor add $(EXTRA_PKGS)
	GOOS=linux GOARCH=amd64 govendor add +external
	GOOS=linux GOARCH=amd64 govendor update +vendor
	cd vendor/github.com/gengo/grpc-gateway/third_party/googleapis && protoeasy --go .

vendor: vendorupdate vendornoupdate

build:
	go build $(PKGS)

install:
	go install $(PKGS) $(EXTRA_CMDS)

proto:
	go get -v go.pedge.io/pkg/cmd/strip-package-comments
	protoeasy
	find . -name *\.pb\*\.go | grep -v vendor | xargs strip-package-comments

example-complete:
	rm -rf _example-out/complete
	protoeasy \
		--no-file \
		--out=_example-out/complete \
		--cpp --cpp-rel-out=cpp \
		--csharp --csharp-rel-out=csharp \
		--objc --objc-rel-out=objc \
		--python --python-rel-out=python \
		--ruby --ruby-rel-out=ruby \
		--go --go-rel-out=go --go-import-path=go.pedge.io/protoeasy/_example-out/complete/go \
		--grpc \
		--grpc-gateway \
		example/complete
	go build ./_example-out/complete/go/...

example-complete-file:
	rm -rf _example-out/complete
	protoeasy --out=_example-out/complete -f protoeasy-example-complete.yaml
	go build ./_example-out/complete/go/...

example-proto2:
	rm -rf _example-out/proto2
	protoeasy \
		--out=_example-out/proto2 \
		--cpp --cpp-rel-out=cpp \
		--python --python-rel-out=python \
		--go --go-rel-out=go --go-import-path=go.pedge.io/protoeasy/_example-out/proto2/go \
		--gogo --gogo-rel-out=gogo --gogo-import-path=go.pedge.io/protoeasy/_example-out/proto2/gogo \
		--grpc \
		example/proto2
	go build ./_example-out/proto2/go/...
	go build ./_example-out/proto2/gogo/...

examples: install example-complete example-complete-file example-proto2

lint:
	go get -v github.com/golang/lint/golint
	for file in $$(find . -name '*.go' | grep -v '^\./_example-out' | grep -v '^\./vendor' | grep -v '\.pb\.go'); do \
		golint $$file; \
		if [ -n "$$(golint $$file)" ]; then \
			exit 1; \
		fi; \
	done

vet:
	go vet $(PKGS)

errcheck:
	go get -v github.com/kisielk/errcheck
	errcheck $(PKGS)

#pretest: lint vet errcheck
pretest: lint vet

test: pretest
	go test $(PKGS)

clean:
	go clean -i $(PKGS)
	rm -rf _example-out

docker-build:
	docker build -t quay.io/pedge/protoeasy .

docker-push: docker-build
	docker push quay.io/pedge/protoeasy

docker-pull:
	docker pull quay.io/pedge/protoeasy

docker-launch:
	docker rm -f protoeasy || true
	docker run -d -p 6789:6789 --name=protoeasy quay.io/pedge/protoeasy

docker-test: docker-build
	docker run quay.io/pedge/protoeasy make test

docker-build-proto2:
	docker build -t quay.io/pedge/protoeasy-proto2 -f Dockerfile.proto2 .

docker-push-proto2: docker-build-proto2
	docker push quay.io/pedge/protoeasy-proto2

docker-pull-proto2:
	docker pull quay.io/pedge/protoeasy

docker-launch-proto2:
	docker rm -f protoeasy-proto2 || true
	docker run -d -p 6789:6789 --name=protoeasy-proto2 quay.io/pedge/protoeasy-proto2

integration: build docker-build docker-launch proto examples

docker-integration: build docker-build
	docker run quay.io/pedge/protoeasy make proto examples

.PHONY: \
	all \
	deps \
	updatedeps \
	testdeps \
	updatetestdeps \
	vendorupdate \
	vendornoupdate \
	vendor \
	build \
	install \
	proto \
	example-complete \
	example-complete-file \
	example-proto2 \
	examples \
	lint \
	vet \
	errcheck \
	pretest \
	test \
	clean \
	docker-build \
	docker-push \
	docker-pull \
	docker-launch \
	docker-test \
	docker-build-proto2 \
	docker-push-proto2 \
	docker-pull-proto2 \
	docker-launch-proto2 \
	integration \
	docker-integration
