all: test

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

lint: testdeps
	go get -v github.com/golang/lint/golint
	for file in $$(find . -name '*.go' | grep -v '\.pb.go$$' | grep -v 'testing/' | grep -v 'benchmark/'); do \
		golint $$file | grep -v underscore; \
		if [ -n "$$(golint $$file | grep -v underscore)" ]; then \
			exit 1; \
		fi; \
	done

vet: testdeps
	go vet ./...

errcheck: testdeps
	go get -v github.com/kisielk/errcheck
	errcheck ./...

pretest: lint vet errcheck

test: testdeps pretest
	go test -test.v ./testing

bench-marshal: testdeps
	go get -v go.pedge.io/tools/go-benchmark-columns
	go test -test.v -bench . ./benchmark/marshal | go-benchmark-columns

bench-long: testdeps
	go get -v go.pedge.io/tools/go-benchmark-columns
	go test -test.v -bench . ./benchmark/long | go-benchmark-columns

clean:
	go clean -i ./...

proto:
	go get -v go.pedge.io/protoeasy/cmd/protoeasy
	go get -v go.pedge.io/pkg/cmd/strip-package-comments
	protoeasy
	strip-package-comments testing/testing.pb.go

docker-build:
	docker build -t quay.io/pedge/protolog .

docker-test: docker-build
	docker run quay.io/pedge/protolog make test

.PHONY: \
	all \
	deps \
	updatedeps \
	testdeps \
	updatetestdeps \
	build \
	lint \
	vet \
	errcheck \
	pretest \
	test \
	bench-marshal \
	bench-long \
	clean \
	proto \
	docker-build \
	docker-test
