SHELL = bash

GO ?= go
GOBIN ?= $(GOPATH)/bin

TERRAFORM ?= $(GOBIN)/terraform
TERRAFORM_SRC = $(shell find $(GOPATH)/src/github.com/hashicorp/terraform -type f)

TERRAFORM_OPTS ?=
TERRAFORM_DIR ?= aws/pardotops
TERRAFORM_PLAN ?= $(TERRAFORM_DIR)/plan.out
TERRAFORM_VAR_FILE ?= terraform.tfvars

ARTIFACTORY_USERNAME ?=
ARTIFACTORY_PASSWORD ?=

-include artifactory.env
ARTIFACTORY_URL := https://artifactory.dev.pardot.com/artifactory
ARTIFACTORY_REPO := pd-terraform

apply: $(TERRAFORM) $(TERRAFORM_DIR) $(TERRAFORM_PLAN) remote-state
	cd $(TERRAFORM_DIR) && \
		$< apply $(TERRAFORM_OPTS) $(TERRAFORM_PLAN)
	rm -f $(TERRAFORM_PLAN)

plan: $(TERRAFORM) $(TERRAFORM_DIR) validate remote-state
	cd $(TERRAFORM_DIR) && \
		$< plan -out $(TERRAFORM_PLAN) -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

pull: $(TERRAFORM) $(TERRAFORM_DIR) remote-state
	cd $(TERRAFORM_DIR) && \
		cp .terraform/terraform.tfstate .terraform/terraform.tfstate.$(shell date +%Y%m%d%H%M%S); \
		$< remote pull $(TERRAFORM_OPTS)

push: $(TERRAFORM) $(TERRAFORM_DIR)
	cd $(TERRAFORM_DIR) && \
		cp .terraform/terraform.tfstate .terraform/terraform.tfstate.$(shell date +%Y%m%d%H%M%S); \
		$< remote push $(TERRAFORM_OPTS)

refresh: $(TERRAFORM) $(TERRAFORM_DIR) $(TERRAFORM_VAR_FILE) remote-state
	$< refresh -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS) $(TERRAFORM_DIR)

remote-state: $(TERRAFORM) $(TERRAFORM_DIR)
	cd $(TERRAFORM_DIR) && \
		$< remote config \
			-backend=artifactory \
			-backend-config="username=$(ARTIFACTORY_USERNAME)" \
			-backend-config="password=$(ARTIFACTORY_ENCRYPTED_PASSWORD)" \
			-backend-config="url=$(ARTIFACTORY_URL)" \
			-backend-config="repo=$(ARTIFACTORY_REPO)" \
			-backend-config="subpath=$(TERRAFORM_PROJECT)"

validate: $(TERRAFORM)
	find . -type d -mindepth 2 -not -name '.terraform' -print0 | \
		xargs -0 -n1 $< validate

$(TERRAFORM): $(TERRAFORM_SRC)
	$(GO) install github.com/hashicorp/terraform

.PHONY: \
	apply \
	plan \
	remote-state \
	refresh \
	validate \
	pull \
	push
