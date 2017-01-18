resource "github_repository" "workflow-stats" {
  name          = "workflow-stats"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "workflow-stats_developers" {
  repository = "${github_repository.workflow-stats.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "workflow-stats_service-accounts-read-only" {
  repository = "${github_repository.workflow-stats.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "workflow-stats_service-accounts-write-only" {
  repository = "${github_repository.workflow-stats.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "workflow-stats_engineering-managers" {
  repository = "${github_repository.workflow-stats.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "workflow-stats_site-reliability-engineers" {
  repository = "${github_repository.workflow-stats.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_branch_protection" "workflow-stats_master" {
  repository = "${github_repository.workflow-stats.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["Test Jobs"]
}
