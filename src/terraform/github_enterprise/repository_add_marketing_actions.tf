resource "github_repository" "add_marketing_actions" {
  name          = "add_marketing_actions"
  description   = "Simple script for creating visitor activity. The primary purpose of this application is to test and demo leaddeck"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "add_marketing_actions_developers" {
  repository = "${github_repository.add_marketing_actions.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "add_marketing_actions_service-accounts-read-only" {
  repository = "${github_repository.add_marketing_actions.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
