resource "github_repository" "testdata" {
  name          = "testdata"
  description   = "An API for the management of data needed for various frameworks which are decoupled from the Pardot codebase."
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "testdata_master" {
  repository = "${github_repository.testdata.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "testdata_developers" {
  repository = "${github_repository.testdata.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "testdata_service-accounts-write-only" {
  repository = "${github_repository.testdata.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "testdata_service-accounts-administrators" {
  repository = "${github_repository.testdata.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
