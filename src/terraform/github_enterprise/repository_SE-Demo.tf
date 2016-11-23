resource "github_repository" "SE-Demo" {
  name          = "SE-Demo"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "SE-Demo_service-accounts-read-only" {
  repository = "${github_repository.SE-Demo.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
