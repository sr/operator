resource "github_repository" "haproxy-1-5" {
  name          = "haproxy-1.5"
  description   = "The Reliable, High Performance TCP/HTTP Load Balancer"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "haproxy-1-5_ops" {
  repository = "${github_repository.haproxy-1-5.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
