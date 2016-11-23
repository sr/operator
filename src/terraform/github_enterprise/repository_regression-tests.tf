resource "github_repository" "regression-tests" {
  name          = "regression-tests"
  description   = "Pardot regression test suite in Ruby's Watir framework."
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "regression-tests_service-accounts-read-only" {
  repository = "${github_repository.regression-tests.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "regression-tests_developers" {
  repository = "${github_repository.regression-tests.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
