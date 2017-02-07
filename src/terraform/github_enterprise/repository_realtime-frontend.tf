resource "github_repository" "realtime-frontend" {
  name          = "realtime-frontend"
  description   = "Realtime frontend server"
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "realtime-frontend_developers" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "realtime-frontend_service-accounts-write-only" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "realtime-frontend_service-accounts-read-only" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "realtime-frontend_site-reliability-engineers" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "realtime-frontend_engineering-managers" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_branch_protection" "realtime-frontend_master" {
  repository = "${github_repository.realtime-frontend.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}
