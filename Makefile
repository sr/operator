export PATH := bin/:$(PATH)
DOCKER ?= docker
ERRCHECK = $(GOBIN)/errcheck
GO ?= go
GOFMT ?= gofmt
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
	$< --go --grpc --go-import-path $(PACKAGE) --exclude protoeasy .

fmt:
	@ for file in $$(find . -name '*.go' | grep -v -E '^\.\/_example|^\.\/vendor|\.pb\.go$$'); do \
			out="$$($(GOFMT) -s -d $$file)"; \
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
	fmt \
	lint \
	vet \
	errcheck
