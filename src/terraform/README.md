# Terraform

Declarative infrastructure.

This README is not a substitute for the [Terraform docs](https://www.terraform.io/docs/index.html). Start there first.

## Plans

This repository supports multiple "plans". Generally there is a plan per "thing" that has its own authentication mechanism. For instance, each AWS account should have a separate plan. That way, someone who has access to pardotops but not to pardot-ci can still effectively use this repository.

## 'Terra' Setup

add these to your ~/.bash_profile or ~/.bashrc
```bash
export GOPATH="<base bread repo checkout path>"
export PATH=$GOPATH/bin:$PATH
```

Grab the "Salesforce Authenticator" app on your company phone. Browse to https://canoe.dev.pardot.com and authenticate. Then browse to https://canoe.dev.pardot.com/auth/phone and when it asks for a code, go to your phone/salesforce-authenticator app, and hit " + New Account ", and supply the two word code to Canoe.

## Authentication

### Artifactory

We store our Terraform state in [Artifactory](https://artifactory.dev.pardot.com). You'll need to be a member of the `terraform_users` group there to use Terraform.

You'll need to setup `artifactory.env` to contain credentials for Artifactory. The `artifactory.env.example` file is a starting place:

```bash
cp artifactory.env.example artifactory.env
vim artifactory.env # fill in the variables
```

Your Artifactory encrypted password can be found on your [profile page](https://artifactory.dev.pardot.com/artifactory/webapp/#/profile).

### Other Credentials

You'll need to setup `terraform.tfvars` to contain credentials for the things you have access to. The `terraform.tfvars.example` file is a starting place:

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars # fill in the things you need
```

## Planning

Generally you want to first run Terraform in plan mode. It'll tell you what it _would_ do you if you applied the plan:

```bash
terra plan aws/pardotops
```

## Applying

When your plan looks good, apply it:

```bash
terra apply aws/pardotops
```

Checkout `terra --help` for other available commands.
