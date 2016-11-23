resource "github_repository" "Discovery-Agent" {
  name          = "Discovery-Agent"
  description   = "Agent for checking health of pardot services and publishing results to the Discovery Service"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
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
