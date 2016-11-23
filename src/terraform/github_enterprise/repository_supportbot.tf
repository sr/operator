resource "github_repository" "supportbot" {
  name          = "supportbot"
  description   = "A supporting, positive and self-starting robit"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "supportbot_developers" {
  repository = "${github_repository.supportbot.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "supportbot_service-accounts-read-only" {
  repository = "${github_repository.supportbot.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
