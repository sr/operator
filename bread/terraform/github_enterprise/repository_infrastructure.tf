resource "github_repository" "infrastructure" {
  name          = "infrastructure"
  description   = "Most things related to developing and maintaining the build and production infrastructure that supports the Pardot business."
  homepage_url  = "https://confluence.dev.pardot.com/display/PTechops/Pardot+TechOps"
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_branch_protection" "infrastructure_master" {
  repository = "${github_repository.infrastructure.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "infrastructure_service-accounts-write-only" {
  repository = "${github_repository.infrastructure.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "infrastructure_developers" {
  repository = "${github_repository.infrastructure.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "infrastructure_service-accounts-read-only" {
  repository = "${github_repository.infrastructure.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "infrastructure_service-accounts-administrators" {
  repository = "${github_repository.infrastructure.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
