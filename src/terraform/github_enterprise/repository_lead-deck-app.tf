resource "github_repository" "lead-deck-app" {
  name          = "lead-deck-app"
  description   = "Client side application for Lead Deck"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "lead-deck-app_developers" {
  repository = "${github_repository.lead-deck-app.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "lead-deck-app_service-accounts-write-only" {
  repository = "${github_repository.lead-deck-app.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "lead-deck-app_service-accounts-read-only" {
  repository = "${github_repository.lead-deck-app.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "lead-deck-app_site-reliability-engineers" {
  repository = "${github_repository.lead-deck-app.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "lead-deck-app_engineering-managers" {
  repository = "${github_repository.lead-deck-app.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "lead-deck-app_service-accounts-admins" {
  repository = "${github_repository.lead-deck-app.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
