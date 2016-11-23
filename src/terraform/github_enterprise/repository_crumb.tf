resource "github_repository" "crumb" {
  name          = "crumb"
  description   = "A cookie manager (including signing functionality)"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "crumb_developers" {
  repository = "${github_repository.crumb.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "crumb_ops" {
  repository = "${github_repository.crumb.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
