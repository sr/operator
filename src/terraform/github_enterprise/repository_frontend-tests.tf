resource "github_repository" "frontend-tests" {
  name          = "frontend-tests"
  description   = "A front-end test suite for the Pardot application"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "frontend-tests_developers" {
  repository = "${github_repository.frontend-tests.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "frontend-tests_service-accounts-read-only" {
  repository = "${github_repository.frontend-tests.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
