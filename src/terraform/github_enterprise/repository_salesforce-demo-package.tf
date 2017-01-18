resource "github_repository" "salesforce-demo-package" {
  name          = "salesforce-demo-package"
  description   = "Repo to build a package just for demoing Engage / Pardot"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
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

resource "github_team_repository" "salesforce-demo-package_site-reliability-engineers" {
  repository = "${github_repository.salesforce-demo-package.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "salesforce-demo-package_engineering-managers" {
  repository = "${github_repository.salesforce-demo-package.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}
