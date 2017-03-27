resource "github_repository" "rmux" {
  name          = "rmux"
  description   = "A Redis Connection Pooler and Multiplexer"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "rmux_master" {
  repository = "${github_repository.rmux.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "rmux_developers" {
  repository = "${github_repository.rmux.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "rmux_service-accounts-read-only" {
  repository = "${github_repository.rmux.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "rmux_service-accounts-write-only" {
  repository = "${github_repository.rmux.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "rmux_service-accounts-administrators" {
  repository = "${github_repository.rmux.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
