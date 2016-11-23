resource "github_repository" "lobster" {
  name          = "lobster"
  description   = "Tool for running reduction queries over apache access log files"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "lobster_developers" {
  repository = "${github_repository.lobster.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "lobster_service-accounts-read-only" {
  repository = "${github_repository.lobster.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
