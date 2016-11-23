resource "github_repository" "parbot" {
  name          = "parbot"
  description   = "This repository has been moved to https://git.dev.pardot.com/Pardot/bread"
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "parbot_service-accounts-read-only" {
  repository = "${github_repository.parbot.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "parbot_ops" {
  repository = "${github_repository.parbot.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
