export GO15VENDOREXPERIMENT := 1
export PATH := bin/:$(PATH)
DOCKER ?= docker
ERRCHECK = $(GOBIN)/errcheck
GO ?= go
GOFMT ?= $(GOROOT)/bin/gofmt
GOLINT ?= $(GOBIN)/golint
PACKAGE ?= github.com/sr/operator
PROTOEASY = $(GOBIN)/protoeasy
VERSION ?= $(shell git rev-parse --short HEAD)

ci: clean fmt lint vet errcheck install

ci-docker: docker-build-grpc docker-build-ci docker-build-operatorc
	$(DOCKER) run --rm srozet/operator/ci

docker-build-grpc:
	$(DOCKER) build -t srozet/operator/grpc -f etc/docker/Dockerfile.grpc .

docker-build-ci:
	$(DOCKER) build -t srozet/operator/ci -f etc/docker/Dockerfile.ci .

docker-build-operatorc:
	$(DOCKER) build -t srozet/operator/operatorc -f etc/docker/Dockerfile.operatorc .

proto: $(PROTOEASY)
	$< --go --grpc --go-import-path $(PACKAGE) \
		--go-modifier vendor/github.com/sr/grpcinstrument/grpcinstrument.proto=github.com/sr/grpcinstrument \
		--exclude _example,vendor,protoeasy .

build:
	$(GO) build -v ./...

install:
	$(GO) install -v ./...

clean:
	$(GO) clean -i ./...

fmt: $(GOFMT)
	@ for file in $$(find . -name '*.go' | grep -v -E '^\.\/_example|^\.\/vendor|\.pb\.go$$'); do \
			out="$$($< -s -d $$file)"; \
			if [ -n "$$out" ]; then \
				echo "$$out"; \
				exit 1; \
			fi \
	  done

lint: $(GOLINT)
	@ for file in $$(find . -name '*.go' | grep -v -E '^\.\/_example|^\.\/vendor|\.pb\.go$$'); do \
			out="$$($< $$file | grep -v 'should have comment')"; \
			if [ -n "$$out" ]; then \
				echo "$$out"; \
				exit 1; \
			fi \
	  done

vet:
	@ for pkg in $$(go list ./... | grep -v $(PACKAGE)/vendor); do \
			out="$$(go vet $$pkg)"; \
			if [ -n "$$out" ]; then \
				echo "$$out"; \
				exit 1; \
			fi \
	  done

errcheck: $(ERRCHECK)
	@ for pkg in $$(go list ./... | grep -v $(PACKAGE)/vendor); do \
			$< $$pkg; \
		done

example-vendor:
	rm -rf _example/vendor/src/github.com/sr/operator
	for file in $$(gvt list -f "{{.Importpath}}"); do \
		rm -rf _example/vendor/src/$$file; \
	done
	cp -r vendor/* _example/vendor/src/
	rm -f _example/vendor/src/manifest
	mkdir -p  _example/vendor/src/github.com/sr/operator
	cp -r cmd generator pb proto protoeasy server _example/vendor/src/github.com/sr/operator
	rm -rf _example/vendor/src/github.com/sr/operator/protoeasy/.git
	git add -A _example/vendor/src _example/vendor/src/github.com/sr/operator
	git add -u _example/vendor/src _example/vendor/src/github.com/sr/operator

$(ERRCHECK):
	$(GO) get -v github.com/kisielk/errcheck

$(GOLINT):
	$(GO) get -v github.com/golang/lint/golint

$(PROTOEASY):
	$(GO) get -v go.pedge.io/protoeasy/cmd/protoeasy


.PHONY: \
	ci \
	ci-docker \
	docker-build-grpc \
	docker-build-ci \
	docker-build-operatorc \
	proto \
	build \
	install \
	clean \
	fmt \
	lint \
	vet \
	errcheck \
	example-vendor
