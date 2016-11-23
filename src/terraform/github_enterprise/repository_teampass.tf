resource "github_repository" "teampass" {
  name          = "teampass"
  description   = "Collaborative Passwords Manager http://www.teampass.net"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "teampass_ops" {
  repository = "${github_repository.teampass.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
