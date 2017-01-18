resource "github_repository" "breakout" {
  name          = "breakout"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "breakout_developers" {
  repository = "${github_repository.breakout.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "breakout_read-only-users" {
  repository = "${github_repository.breakout.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "breakout_site-reliability-engineers" {
  repository = "${github_repository.breakout.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "breakout_engineering-managers" {
  repository = "${github_repository.breakout.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}
