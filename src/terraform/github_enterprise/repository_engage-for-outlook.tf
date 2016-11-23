resource "github_repository" "engage-for-outlook" {
  name          = "engage-for-outlook"
  description   = "Outlook 365 plugin for Engage"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "engage-for-outlook_developers" {
  repository = "${github_repository.engage-for-outlook.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
