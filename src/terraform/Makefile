TERRAFORM ?= terraform
TERRAFORM_OPTS ?=
ARTIFACTORY_USERNAME ?=
ARTIFACTORY_PASSWORD ?=
DIR ?= aws/pardotops

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TERRAFORM_VAR_FILE := $(ROOT_DIR)/terraform.tfvars

-include artifactory.env
ARTIFACTORY_URL := https://artifactory.dev.pardot.com/artifactory
ARTIFACTORY_REPO := pd-terraform

.PHONY: artifactory-remote-state
artifactory-remote-state: $(DIR)
	cd $(DIR) && \
	$(TERRAFORM) remote config \
		-backend=artifactory \
		-backend-config="username=$(ARTIFACTORY_USERNAME)" \
		-backend-config="password=$(ARTIFACTORY_ENCRYPTED_PASSWORD)" \
		-backend-config="url=$(ARTIFACTORY_URL)" \
		-backend-config="repo=$(ARTIFACTORY_REPO)" \
		-backend-config="subpath=$(DIR)"

.PHONY: plan
plan: artifactory-remote-state validate
	cd $(DIR) && $(TERRAFORM) plan -out plan.out -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

.PHONY: apply
apply: artifactory-remote-state $(DIR)/plan.out
	cd $(DIR) && $(TERRAFORM) apply $(TERRAFORM_OPTS) plan.out
	cd $(DIR) && rm -f plan.out

.PHONY: refresh
refresh: artifactory-remote-state
	cd $(DIR) && $(TERRAFORM) refresh -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

.PHONY: validate
validate:
	find . -type d -mindepth 2 -not -name '.terraform' -print0 | xargs -0 -n1 terraform validate
