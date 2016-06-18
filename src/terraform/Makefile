GO ?= go
GOBIN ?= $(GOPATH)/bin

TERRAFORM ?= $(GOBIN)/terraform
TERRAFORM_SRC = $(shell find $(GOPATH)/src/github.com/hashicorp/terraform -type f)

ARTIFACTORY_USERNAME ?=
ARTIFACTORY_PASSWORD ?=

DIR ?= aws/pardotops

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TERRAFORM_VAR_FILE := $(ROOT_DIR)/terraform.tfvars
TERRAFORM_OPTS ?=

-include artifactory.env
ARTIFACTORY_URL := https://artifactory.dev.pardot.com/artifactory
ARTIFACTORY_REPO := pd-terraform

.PHONY: artifactory-remote-state
artifactory-remote-state: $(TERRAFORM) $(DIR)
	cd $(DIR) && \
	$< remote config \
		-backend=artifactory \
		-backend-config="username=$(ARTIFACTORY_USERNAME)" \
		-backend-config="password=$(ARTIFACTORY_ENCRYPTED_PASSWORD)" \
		-backend-config="url=$(ARTIFACTORY_URL)" \
		-backend-config="repo=$(ARTIFACTORY_REPO)" \
		-backend-config="subpath=$(DIR)"

.PHONY: plan
plan: $(TERRAFORM) artifactory-remote-state validate
	cd $(DIR) && $< plan -out plan.out -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

.PHONY: apply
apply: $(TERRAFORM) artifactory-remote-state $(DIR)/plan.out
	cd $(DIR) && $< apply $(TERRAFORM_OPTS) plan.out
	cd $(DIR) && rm -f plan.out

.PHONY: refresh
refresh: $(TERRAFORM) artifactory-remote-state
	cd $(DIR) && $< refresh -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

.PHONY: validate
validate: $(TERRAFORM)
	find . -type d -mindepth 2 -not -name '.terraform' -print0 | xargs -0 -n1 $< validate

$(TERRAFORM): $(TERRAFORM_SRC)
	$(GO) install github.com/hashicorp/terraform
