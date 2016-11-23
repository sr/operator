resource "github_repository" "selenium-tests" {
  name          = "selenium-tests"
  description   = "SalesForce"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "selenium-tests_developers" {
  repository = "${github_repository.selenium-tests.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "selenium-tests_service-accounts-write-only" {
  repository = "${github_repository.selenium-tests.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "selenium-tests_service-accounts-read-only" {
  repository = "${github_repository.selenium-tests.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
