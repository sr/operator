resource "github_repository" "gmail-firefox" {
  name          = "gmail-firefox"
  description   = "Adds a \"Send with Pardot\" button to GMail / Google Apps"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "gmail-firefox_developers" {
  repository = "${github_repository.gmail-firefox.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "gmail-firefox_service-accounts-read-only" {
  repository = "${github_repository.gmail-firefox.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
