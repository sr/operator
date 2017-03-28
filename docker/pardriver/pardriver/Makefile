ARTIFACTORY_HOST ?= "artifactory.dev.pardot.com"
GIT_DEV_HOST ?= "git.dev.pardot.com"
DOCKER_IMAGE_URL ?= "docker.dev.pardot.com/pardriver/pardriver"
DOCKER ?= docker

.PHONY: build
build: clean pom.xml
	$(DOCKER) build --build-arg artifactory_host=$(ARTIFACTORY_HOST) -t $(DOCKER_IMAGE_URL) .

.PHONY: clean
clean:
	@rm -f pom.xml

pom.xml:
	@curl -sf -o pom.xml \
		-H "Accept: application/vnd.github.v3.raw" \
		-H "Authorization: token $(GIT_DEV_TOKEN)" \
		"https://$(GIT_DEV_HOST)/api/v3/repos/Pardot/pardot/contents/test/pardriver/pom.xml?ref=master"
