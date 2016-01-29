all: test

version:
	@echo 'package main; import "go.pedge.io/openflights"; func main() { openflights.Version.Println() }' > /tmp/openflights_version.go
	@go run /tmp/openflights_version.go

deps:
	go get -d -v ./...

updatedeps:
	go get -d -v -u -f ./...

testdeps:
	go get -d -v -t ./...

updatetestdeps:
	go get -d -v -t -u -f ./...

build: deps
	go build ./...

install: deps
	go install ./...

lint: testdeps
	go get -v github.com/golang/lint/golint
	for file in $$(find . -name '*.go' | grep -v '\.pb\.go' | grep -v '\.pb\.gw\.go'); do \
		golint $${file}; \
		if [ -n "$$(golint $${file})" ]; then \
			exit 1; \
		fi; \
	done

vet: testdeps
	go vet ./...

errcheck: testdeps
	go get -v github.com/kisielk/errcheck
	errcheck ./...

pretest: lint

test: testdeps pretest
	go test ./...

clean:
	go clean -i ./...

proto:
	go get -v go.pedge.io/protoeasy/cmd/protoeasy
	go get -v go.pedge.io/pkg/cmd/strip-package-comments
	protoeasy --go --grpc --grpc-gateway --go-import-path go.pedge.io/openflights .
	find . -name *\.pb\*\.go | xargs strip-package-comments

generate:
	go run cmd/gen-openflights-csv-store/main.go openflights generated.go

docker-build-openflights-dev:
	docker build -t quay.io/pedge/openflights-dev -f Dockerfile.openflights-dev .

docker-build-openflightsd-internal: deps
	rm -rf _tmp
	mkdir -p _tmp
	CGO_ENABLED=0 go build -a -installsuffix cgo -o _tmp/openflightsd cmd/openflightsd/main.go
	docker build -t quay.io/pedge/openflightsd -f Dockerfile.openflightsd .

docker-build-openflightsd: docker-build-openflights-dev
	docker run -v /var/run/docker.sock:/var/run/docker.sock quay.io/pedge/openflights-dev make docker-build-openflightsd-internal

docker-test: docker-build-openflights-dev
	docker run quay.io/pedge/openflights-dev make test

docker-push: docker-build-openflightsd
	docker push quay.io/pedge/openflightsd

launch: docker-build-openflightsd
	docker run -d -p 7070:7070 -p 8080:8080 quay.io/pedge/openflightsd

launch-local: deps
	go run cmd/openflightsd/main.go

.PHONY: \
	all \
	version \
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
	generate \
	docker-build-openflights-dev \
	docker-build-openflightsd-internal \
	docker-build-openflightsd \
	docker-test \
	launch \
	launch-local
