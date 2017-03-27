resource "github_repository" "ParMeter" {
  name          = "ParMeter"
  description   = "JMeter framework for Pardot"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "ParMeter_master" {
  repository = "${github_repository.ParMeter.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "ParMeter_service-accounts-write-only" {
  repository = "${github_repository.ParMeter.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "ParMeter_service-accounts-administrators" {
  repository = "${github_repository.ParMeter.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
