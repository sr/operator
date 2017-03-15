resource "github_repository" "kendo" {
  name          = "kendo"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "kendo_master" {
  repository = "${github_repository.kendo.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "kendo_service-accounts-read-only" {
  repository = "${github_repository.kendo.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "kendo_developers" {
  repository = "${github_repository.kendo.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "kendo_service-accounts-write-only" {
  repository = "${github_repository.kendo.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "kendo_service-accounts-administrators" {
  repository = "${github_repository.kendo.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
