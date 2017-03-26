resource "github_repository" "salesforce-demo-package" {
  name          = "salesforce-demo-package"
  description   = "Repo to build a package just for demoing Engage / Pardot"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "salesforce-demo-package_master" {
  repository = "${github_repository.salesforce-demo-package.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "salesforce-demo-package_developers" {
  repository = "${github_repository.salesforce-demo-package.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "salesforce-demo-package_service-accounts-read-only" {
  repository = "${github_repository.salesforce-demo-package.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "salesforce-demo-package_service-accounts-write-only" {
  repository = "${github_repository.salesforce-demo-package.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "salesforce-demo-package_service-accounts-administrators" {
  repository = "${github_repository.salesforce-demo-package.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
