resource "github_repository" "crumb" {
  name          = "crumb"
  description   = "A cookie manager (including signing functionality)"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "crumb_master" {
  repository = "${github_repository.crumb.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "crumb_developers" {
  repository = "${github_repository.crumb.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "crumb_read-only-users" {
  repository = "${github_repository.crumb.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "crumb_service-accounts-write-only" {
  repository = "${github_repository.crumb.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "crumb_service-accounts-administrators" {
  repository = "${github_repository.crumb.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
