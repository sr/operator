resource "github_repository" "bread" {
  name          = "bread"
  description   = "BREAD team repository"
  homepage_url  = "https://confluence.dev.pardot.com/display/PTechops/BREAD+Ops"
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "bread_service-accounts-write-only" {
  repository = "${github_repository.bread.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "bread_developers" {
  repository = "${github_repository.bread.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "bread_service-accounts-read-only" {
  repository = "${github_repository.bread.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_branch_protection" "bread_master" {
  repository = "${github_repository.bread.name}"
  branch     = "master"

  include_admins = true
  strict         = true
  contexts       = ["BREAD build"]
}
