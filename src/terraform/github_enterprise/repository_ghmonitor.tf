resource "github_repository" "ghmonitor" {
  name          = "ghmonitor"
  description   = "GitHub Monitoring Tools"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "ghmonitor_ops" {
  repository = "${github_repository.ghmonitor.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "ghmonitor_service-accounts-read-only" {
  repository = "${github_repository.ghmonitor.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
