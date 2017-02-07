resource "github_repository" "wax" {
  name          = "wax"
  description   = "Wave Asset Xfer (WAX) - push/pull Salesforce.com Analytics Cloud assets and apps"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "wax_engineering-managers" {
  repository = "${github_repository.wax.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "wax_site-reliability-engineers" {
  repository = "${github_repository.wax.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "wax_service-accounts-write-only" {
  repository = "${github_repository.wax.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
