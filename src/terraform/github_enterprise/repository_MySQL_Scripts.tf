resource "github_repository" "MySQL_Scripts" {
  name          = "MySQL_Scripts"
  description   = "Scripts for MySQL "
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "MySQL_Scripts_ops" {
  repository = "${github_repository.MySQL_Scripts.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "MySQL_Scripts_service-accounts-read-only" {
  repository = "${github_repository.MySQL_Scripts.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
