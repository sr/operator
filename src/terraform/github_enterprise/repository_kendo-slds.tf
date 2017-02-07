resource "github_repository" "kendo-slds" {
  name          = "kendo-slds"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "kendo-slds_developers" {
  repository = "${github_repository.kendo-slds.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "kendo-slds_engineering-managers" {
  repository = "${github_repository.kendo-slds.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "kendo-slds_site-reliability-engineers" {
  repository = "${github_repository.kendo-slds.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "kendo-slds_service-accounts-write-only" {
  repository = "${github_repository.kendo-slds.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
