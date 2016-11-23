resource "github_repository" "chef-ghe_backup" {
  name          = "chef-ghe_backup"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "chef-ghe_backup_ops" {
  repository = "${github_repository.chef-ghe_backup.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "chef-ghe_backup_service-accounts-read-only" {
  repository = "${github_repository.chef-ghe_backup.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
