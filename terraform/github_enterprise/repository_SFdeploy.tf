resource "github_repository" "SFdeploy" {
  name          = "SFdeploy"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "SFdeploy_master" {
  repository = "${github_repository.SFdeploy.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "SFdeploy_developers" {
  repository = "${github_repository.SFdeploy.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "SFdeploy_service-accounts-write-only" {
  repository = "${github_repository.SFdeploy.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "SFdeploy_service-accounts-administrators" {
  repository = "${github_repository.SFdeploy.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
