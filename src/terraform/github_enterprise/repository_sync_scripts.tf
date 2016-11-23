resource "github_repository" "sync_scripts" {
  name          = "sync_scripts"
  description   = "Ruby Sync Scripts"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "sync_scripts_developers" {
  repository = "${github_repository.sync_scripts.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "sync_scripts_ops" {
  repository = "${github_repository.sync_scripts.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "sync_scripts_service-accounts-read-only" {
  repository = "${github_repository.sync_scripts.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
