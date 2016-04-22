ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TERRAFORM_VAR_FILE = "$(ROOT_DIR)/terraform.tfvars"
TERRAFORM = terraform
TERRAFORM_OPTS =
DIR = aws/pardotops

.PHONY: plan
plan: $(DIR) validate
	cd $(DIR) && $(TERRAFORM) plan -out plan.out -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

.PHONY: apply
apply: $(DIR)/plan.out
	cd $(DIR) && $(TERRAFORM) apply $(TERRAFORM_OPTS) plan.out
	cd $(DIR) && rm -f plan.out

.PHONY: refresh
refresh:
	cd $(DIR) && $(TERRAFORM) refresh -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

.PHONY: validate
validate:
	find . -type d -mindepth 2 -print0 | xargs -0 -n1 terraform validate
