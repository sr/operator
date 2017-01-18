resource "github_repository" "ParMeter" {
  name          = "ParMeter"
  description   = "JMeter framework for Pardot"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "ParMeter_site-reliability-engineers" {
  repository = "${github_repository.ParMeter.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "ParMeter_engineering-managers" {
  repository = "${github_repository.ParMeter.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "ParMeter_service-accounts-write-only" {
  repository = "${github_repository.ParMeter.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
