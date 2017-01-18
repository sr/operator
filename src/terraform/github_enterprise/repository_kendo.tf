resource "github_repository" "kendo" {
  name          = "kendo"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "kendo_service-accounts-read-only" {
  repository = "${github_repository.kendo.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "kendo_developers" {
  repository = "${github_repository.kendo.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "kendo_site-reliability-engineers" {
  repository = "${github_repository.kendo.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "kendo_engineering-managers" {
  repository = "${github_repository.kendo.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}
