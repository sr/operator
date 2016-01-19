ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TERRAFORM_VAR_FILE = "$(ROOT_DIR)/terraform.tfvars"
TERRAFORM = terraform
TERRAFORM_OPTS =
PLAN = aws/pardotops

.PHONY: plan
plan: $(PLAN)
	cd $(PLAN) && $(TERRAFORM) plan -out plan.out -var-file=$(TERRAFORM_VAR_FILE) $(TERRAFORM_OPTS)

.PHONY: apply
apply: $(PLAN)/plan.out
	cd $(PLAN) && $(TERRAFORM) apply $(TERRAFORM_OPTS) plan.out
	cd $(PLAN) && rm -f plan.out

.PHONY: refresh
refresh:
	cd $(PLAN) && $(TERRAFORM) refresh $(TERRAFORM_OPTS)
