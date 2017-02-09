resource "github_repository" "SFdeploy" {
  name          = "SFdeploy"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "SFdeploy_developers" {
  repository = "${github_repository.SFdeploy.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "SFdeploy_site-reliability-engineers" {
  repository = "${github_repository.SFdeploy.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "SFdeploy_engineering-managers" {
  repository = "${github_repository.SFdeploy.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "SFdeploy_service-accounts-write-only" {
  repository = "${github_repository.SFdeploy.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "SFdeploy_service-accounts-admins" {
  repository = "${github_repository.SFdeploy.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
