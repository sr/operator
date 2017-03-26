resource "github_repository" "pd-homebrew" {
  name          = "pd-homebrew"
  description   = "Pardot Homebrew"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "pd-homebrew_master" {
  repository = "${github_repository.pd-homebrew.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "pd-homebrew_developers" {
  repository = "${github_repository.pd-homebrew.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pd-homebrew_service-accounts-write-only" {
  repository = "${github_repository.pd-homebrew.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pd-homebrew_service-accounts-administrators" {
  repository = "${github_repository.pd-homebrew.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
