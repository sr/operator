GO15VENDOREXPERIMENT = 1

deps:
	go get -d ./src/...

updatedeps:
	go get -d -u -f ./src/...

testdeps:
	go get -d -t ./src/...

updatetestdeps:
	go get -d -t -u -f ./src/...

build: deps
	go build ./src/...

install: deps
	go install ./src/...

lint: testdeps
	go get github.com/golang/lint/golint
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
	go get github.com/kisielk/errcheck
	errcheck ./src/...

pretest: lint

test: testdeps pretest
	go test ./src/...
