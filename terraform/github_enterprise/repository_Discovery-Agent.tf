resource "github_repository" "Discovery-Agent" {
  name          = "Discovery-Agent"
  description   = "Agent for checking health of pardot services and publishing results to the Discovery Service"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "Discovery-Agent_master" {
  repository = "${github_repository.Discovery-Agent.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "Discovery-Agent_developers" {
  repository = "${github_repository.Discovery-Agent.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "Discovery-Agent_service-accounts-read-only" {
  repository = "${github_repository.Discovery-Agent.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "Discovery-Agent_service-accounts-write-only" {
  repository = "${github_repository.Discovery-Agent.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "Discovery-Agent_service-accounts-administrators" {
  repository = "${github_repository.Discovery-Agent.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
