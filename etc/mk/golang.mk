GB = bin/gb
GBVENDOR = bin/gb-vendor
GOLINT = bin/golint
ERRCHECK = bin/errcheck

$(GB):
	GOPATH="$(shell pwd)/vendor" \
	GOBIN="$(shell pwd)/bin" \
	go install github.com/constabulary/gb/...

$(GBVENDOR): $(GB)
	$< build github.com/constabulary/gb/cmd/gb-vendor

$(GOLINT): $(GB)
	$< build github.com/golang/lint/golint

$(ERRCHECK): $(GB)
	$< build github.com/kisielk/errcheck

build: $(GB)
	$< build all

lint: $(GOLINT)
	go get github.com/golang/lint/golint
	@ for file in $$(find src -name '*.go'); do \
		bin/golint-custom $${file}; \
		failure=false; \
		test -n "$$(bin/golint-custom $${file})" && failure=true; \
	  done; \
	  if $$failure; \
	  then exit 1; \
	  fi

vet:
	go vet ./src/...

errcheck: $(ERRCHECK)
	$< ./src/...

.PHONY: \
	build \
	lint \
	vet \
	errcheck \
