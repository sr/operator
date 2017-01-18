resource "github_repository" "rpms" {
  name          = "rpms"
  description   = "A buildroot for building custom RPMs"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "rpms_developers" {
  repository = "${github_repository.rpms.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "rpms_site-reliability-engineers" {
  repository = "${github_repository.rpms.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "rpms_engineering-managers" {
  repository = "${github_repository.rpms.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}
