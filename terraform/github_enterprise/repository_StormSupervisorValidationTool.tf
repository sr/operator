resource "github_repository" "StormSupervisorValidationTool" {
  name          = "StormSupervisorValidationTool"
  description   = "Quick n Dirty tool to validate Storm Supervisor hosts"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "StormSupervisorValidationTool_master" {
  repository = "${github_repository.StormSupervisorValidationTool.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "StormSupervisorValidationTool_service-accounts-write-only" {
  repository = "${github_repository.StormSupervisorValidationTool.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "StormSupervisorValidationTool_service-accounts-administrators" {
  repository = "${github_repository.StormSupervisorValidationTool.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
