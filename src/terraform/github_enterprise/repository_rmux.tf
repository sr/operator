resource "github_repository" "rmux" {
  name          = "rmux"
  description   = "A Redis Connection Pooler and Multiplexer"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
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

resource "github_team_repository" "rmux_engineering-managers" {
  repository = "${github_repository.rmux.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "rmux_site-reliability-engineers" {
  repository = "${github_repository.rmux.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "rmux_service-accounts-write-only" {
  repository = "${github_repository.rmux.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "rmux_service-accounts-admins" {
  repository = "${github_repository.rmux.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
