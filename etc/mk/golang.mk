export GO15VENDOREXPERIMENT := 1

build:
	go build -v ./cmd/...

install:
	go install -v ./cmd/...

lint: $(GOLINT)
	golint *.go | grep -v '\.pb\.go'
	golint cmd/**/*.go
	golint generator/*.go

vet:
	go vet ./...

errcheck:
	errcheck ./...

.PHONY: \
	build \
	install \
	lint \
	vet \
	errcheck \
