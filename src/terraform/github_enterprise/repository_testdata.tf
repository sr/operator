resource "github_repository" "testdata" {
  name          = "testdata"
  description   = "An API for the management of data needed for various frameworks which are decoupled from the Pardot codebase."
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "testdata_developers" {
  repository = "${github_repository.testdata.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "testdata_engineering-managers" {
  repository = "${github_repository.testdata.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "testdata_site-reliability-engineers" {
  repository = "${github_repository.testdata.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "testdata_service-accounts-write-only" {
  repository = "${github_repository.testdata.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "testdata_service-accounts-admins" {
  repository = "${github_repository.testdata.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
