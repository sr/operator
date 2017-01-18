resource "github_repository" "ParDove" {
  name          = "ParDove"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "ParDove_developers" {
  repository = "${github_repository.ParDove.name}"
  team_id    = "${github_team.developers.id}"
  permission = "pull"
}

resource "github_team_repository" "ParDove_service-accounts-write-only" {
  repository = "${github_repository.ParDove.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
