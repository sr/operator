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

pull: $(TERRAFORM) $(TERRAFORM_DIR)
	cd $(TERRAFORM_DIR) && \
		$< state pull $(TERRAFORM_OPTS)

import: $(TERRAFORM) $(TERRAFORM_DIR) $(TERRAFORM_VAR_FILE)
	cd $(TERRAFORM_DIR) && \
		$< import -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

refresh: $(TERRAFORM) $(TERRAFORM_DIR) $(TERRAFORM_VAR_FILE)
	$< refresh -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS) $(TERRAFORM_DIR)

.PHONY: \
	pull \
	import \
	refresh
