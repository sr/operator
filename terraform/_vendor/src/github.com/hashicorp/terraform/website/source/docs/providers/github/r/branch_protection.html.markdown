---
layout: "github"
page_title: "GitHub: github_branch_protection"
sidebar_current: "docs-github-resource-branch-protection"
description: |-
  Protects a GitHub branch.
---

# github\_branch\_protection

Protects a GitHub branch.

This resource allows you to configure branch protection for repositories in your organization. When applied, the branch will be protected from forced pushes and deletion. Additional constraints, such as required status checks or restrictions on users and teams, can also be configured.

## Example Usage

```
# Protect the master branch of the foo repository. Additionally, require that
# the "ci/travis" context to be passing and only allow the SRE team merge to the
# branch.
resource "github_branch_protection" "foo_master" {
  repository = "foo"
  branch = "master"

  contexts = ["ci/travis"]
  teams_restriction = ["SRE"]
}
```

## Argument Reference

The following arguments are supported:

* `repository` - (Required) The GitHub repository name.
* `branch` - (Required) The Git branch to protect.
* `include_admins` - (Optional) Boolean controlling whether restrictions apply to administrators (Default: `false`).
* `strict` - (Optional) Boolean controller whether branches must be up-to-date before merging (Default: `false`).
* `contexts` - (Optional) The list of status checks to require in order to merge into this branch.
* `users_restriction` - (Optional) The list of user logins with push access.
* `teams_restriction` - (Optional) The list of team slugs with push access.
