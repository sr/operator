resource "github_repository" "StormSupervisorValidationTool" {
  name          = "StormSupervisorValidationTool"
  description   = "Quick n Dirty tool to validate Storm Supervisor hosts"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "StormSupervisorValidationTool_engineering-managers" {
  repository = "${github_repository.StormSupervisorValidationTool.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "StormSupervisorValidationTool_site-reliability-engineers" {
  repository = "${github_repository.StormSupervisorValidationTool.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "StormSupervisorValidationTool_service-accounts-write-only" {
  repository = "${github_repository.StormSupervisorValidationTool.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
