resource "github_repository" "redis-monitor" {
  name          = "redis-monitor"
  description   = "A monitor for redis status"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "redis-monitor_developers" {
  repository = "${github_repository.redis-monitor.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
