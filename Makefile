ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TERRAFORM_OPTS += -var-file="$(ROOT_DIR)/terraform.tfvars"
TERRAFORM = terraform
PLAN = aws/pardotops

.PHONY: plan
plan:
	cd $(PLAN) && $(TERRAFORM) plan $(TERRAFORM_OPTS)

.PHONY: apply
apply:
	cd $(PLAN) && $(TERRAFORM) apply $(TERRAFORM_OPTS)

.PHONY: refresh
refresh:
	cd $(PLAN) && $(TERRAFORM) refresh $(TERRAFORM_OPTS)
