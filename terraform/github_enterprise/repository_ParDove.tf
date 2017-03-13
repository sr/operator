resource "github_repository" "ParDove" {
  name          = "ParDove"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "ParDove_master" {
  repository = "${github_repository.ParDove.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
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

resource "github_team_repository" "ParDove_service-accounts-administrators" {
  repository = "${github_repository.ParDove.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
