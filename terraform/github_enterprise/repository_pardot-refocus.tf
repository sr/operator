resource "github_repository" "pardot-refocus" {
  name          = "pardot-refocus"
  description   = "App to feed Pardot metrics to Refocus"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "pardot-refocus_master" {
  repository = "${github_repository.pardot-refocus.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "pardot-refocus_developers" {
  repository = "${github_repository.pardot-refocus.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-refocus_service-accounts-write-only" {
  repository = "${github_repository.pardot-refocus.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-refocus_service-accounts-administrators" {
  repository = "${github_repository.pardot-refocus.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
