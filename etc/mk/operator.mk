DOCKER ?= docker
GO ?= go
TMPDIR ?= /tmp

BREAD ?= $(GOPATH)/src/git.dev.pardot.com/Pardot/bread
BREAD_IMPORT_PATH ?= git.dev.pardot.com/Pardot/bread
OPERATORD_LINUX ?= $(TMPDIR)/operatord_linux

generate:
	@ echo Please use "tools/protogen" to generate protobuf files instead
	@ exit 1

ldap-dev: docker-build-ldap
	$(DOCKER) stop -t 3 operator_ldap >/dev/null || true
	$(DOCKER) rm operator_ldap >/dev/null || true
	$(DOCKER) run --name "operator_ldap" -P -d \
		-v "$(BREAD)/etc/ldap.ldif:/data/ldap.ldif" bread/ldap >/dev/null

test: etc/ldap.ldif ldap-dev
	export LDAP_PORT_389_TCP_PORT="$$(docker inspect -f '{{(index (index .NetworkSettings.Ports "389/tcp") 0).HostPort }}' operator_ldap)"; \
	export LDAP_PORT_389_TCP_ADDR="localhost"; \
	$(GO) test $$($(GO) list bread/... | grep -v bread/vendor) -ldap github.com/sr/operator/...

build-operatord: $(TMPDIR)
	env CGO_ENABLED=0 GOOS=linux $(GO) build -a -tags netgo -ldflags "-w" \
		-o $(OPERATORD_LINUX) $(BREAD_IMPORT_PATH)/cmd/operatord

docker-build-ldap:
	docker build -f etc/docker/Dockerfile.ldap -t bread/ldap $(BREAD)

docker-build-operatord: etc/docker/ca-bundle.crt $(OPERATORD_LINUX)
	cp $(OPERATORD_LINUX) operatord
	$(DOCKER) build -f $(BREAD)/etc/docker/Dockerfile.operatord -t operatord_app $(BREAD)
	rm -f operatord

etc/docker/ca-bundle.crt:
	$(DOCKER) run docker.dev.pardot.com/base/centos:7 cat /etc/pki/tls/certs/ca-bundle.crt > $@

.PHONY: \
	build-operatord \
	docker-build-operatord \
	docker-build-ldap \
	generate \
	ldap-dev \
	test
