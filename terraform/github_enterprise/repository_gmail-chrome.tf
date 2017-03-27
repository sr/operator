resource "github_repository" "gmail-chrome" {
  name          = "gmail-chrome"
  description   = "Pardot GMail / gApps plugin for Google Chrome"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "gmail-chrome_master" {
  repository = "${github_repository.gmail-chrome.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "gmail-chrome_developers" {
  repository = "${github_repository.gmail-chrome.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "gmail-chrome_service-accounts-read-only" {
  repository = "${github_repository.gmail-chrome.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "gmail-chrome_service-accounts-write-only" {
  repository = "${github_repository.gmail-chrome.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "gmail-chrome_service-accounts-administrators" {
  repository = "${github_repository.gmail-chrome.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
