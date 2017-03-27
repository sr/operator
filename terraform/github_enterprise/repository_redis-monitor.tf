resource "github_repository" "redis-monitor" {
  name          = "redis-monitor"
  description   = "A monitor for redis status"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "redis-monitor_master" {
  repository = "${github_repository.redis-monitor.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "redis-monitor_developers" {
  repository = "${github_repository.redis-monitor.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "redis-monitor_service-accounts-write-only" {
  repository = "${github_repository.redis-monitor.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "redis-monitor_service-accounts-administrators" {
  repository = "${github_repository.redis-monitor.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
