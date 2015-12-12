GO15VENDOREXPERIMENT = 1

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
	@ for file in $$(find src -name '*.go'); do \
		bin/golint $${file}; \
		failure=false; \
		test -n "$$(bin/golint $${file})" && failure=true; \
	  done; \
	  if $$failure; \
	  then exit 1; \
	  fi

vet: testdeps
	go vet ./src/...

errcheck: testdeps
	go get -v github.com/kisielk/errcheck
	errcheck ./src/...

pretest: lint

test: testdeps pretest
	go test ./src/...
