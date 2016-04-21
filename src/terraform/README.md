# Terraform

Declarative infrastructure.

This README is not a substitute for the [Terraform docs](https://www.terraform.io/docs/index.html). Start there first.

## Plans

This repository supports multiple "plans". Generally there is a plan per "thing" that has its own authentication mechanism. For instance, each AWS account should have a separate plan. That way, someone who has access to pardotops but not to pardot-ci can still effectively use this repository.

## Authentication

You'll need to setup `terraform.tfvars` to contain credentials for the things you have access to. The `terraform.tfvars.example` file is a starting place:

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars # fill in the things you need
```

## Planning

Generally you want to first run Terraform in plan mode. It'll tell you what it _would_ do you if you applied the plan:

```bash
make plan DIR=aws/pardotops
```

## Applying

When your plan looks good, apply it:

```bash
make apply DIR=aws/pardotops
```

**Important:** Terraform will update a `.tfstate` file in the directory. It is important that you commit this and merge it into master as soon as possible to avoid merge conflicts with your coworkers. In the future, we might use [remote state](https://www.terraform.io/docs/state/remote.html) to allay this gotcha.
