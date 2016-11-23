resource "github_repository" "AutomationEngine" {
  name          = "AutomationEngine"
  description   = "Engines for Automations"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "AutomationEngine_developers" {
  repository = "${github_repository.AutomationEngine.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "AutomationEngine_service-accounts-read-only" {
  repository = "${github_repository.AutomationEngine.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
