resource "github_repository" "native-setup-scripts" {
  name          = "native-setup-scripts"
  description   = "Native Setup Scripts"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "native-setup-scripts_developers" {
  repository = "${github_repository.native-setup-scripts.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "native-setup-scripts_service-accounts-read-only" {
  repository = "${github_repository.native-setup-scripts.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
