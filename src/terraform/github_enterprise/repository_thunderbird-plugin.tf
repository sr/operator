resource "github_repository" "thunderbird-plugin" {
  name          = "thunderbird-plugin"
  description   = "Thunderbird Plugin for Pardot"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "thunderbird-plugin_developers" {
  repository = "${github_repository.thunderbird-plugin.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "thunderbird-plugin_service-accounts-read-only" {
  repository = "${github_repository.thunderbird-plugin.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
