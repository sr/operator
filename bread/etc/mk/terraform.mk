SHELL = bash

GO ?= go
GOBIN ?= $(GOPATH)/bin

TERRAFORM ?= $(GOBIN)/terraform

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

pull: $(TERRAFORM) $(TERRAFORM_DIR)
	cd $(TERRAFORM_DIR) && \
		$< state pull $(TERRAFORM_OPTS)

import: $(TERRAFORM) $(TERRAFORM_DIR) $(TERRAFORM_VAR_FILE) remote-state
	cd $(TERRAFORM_DIR) && \
		$< import -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

refresh: $(TERRAFORM) $(TERRAFORM_DIR) $(TERRAFORM_VAR_FILE) remote-state
	$< refresh -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS) $(TERRAFORM_DIR)

.PHONY: \
	pull \
	import \
	refresh
