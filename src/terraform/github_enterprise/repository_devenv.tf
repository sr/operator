resource "github_repository" "devenv" {
  name          = "devenv"
  description   = "[DEPRECATED] See README.md for more details"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "devenv_developers" {
  repository = "${github_repository.devenv.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "devenv_ops" {
  repository = "${github_repository.devenv.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
