resource "github_repository" "sf-push-upgrade" {
  name          = "sf-push-upgrade"
  description   = "API wrapper for \"Salesforce Push Upgrade\""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "sf-push-upgrade_developers" {
  repository = "${github_repository.sf-push-upgrade.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "sf-push-upgrade_ops" {
  repository = "${github_repository.sf-push-upgrade.name}"
  team_id    = "${github_team.ops.id}"
  permission = "admin"
}
