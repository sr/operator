resource "github_repository" "murda" {
  name          = "murda"
  description   = "Rapid fake data generator for pardot"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "murda_developers" {
  repository = "${github_repository.murda.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "murda_service-accounts-read-only" {
  repository = "${github_repository.murda.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
