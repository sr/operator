resource "github_repository" "premail_api" {
  name          = "premail_api"
  description   = "API that wraps the premail gem"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "premail_api_service-accounts-read-only" {
  repository = "${github_repository.premail_api.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
