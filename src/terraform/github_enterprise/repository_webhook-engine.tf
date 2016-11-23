resource "github_repository" "webhook-engine" {
  name          = "webhook-engine"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "webhook-engine_developers" {
  repository = "${github_repository.webhook-engine.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
