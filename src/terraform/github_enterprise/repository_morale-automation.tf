resource "github_repository" "morale-automation" {
  name          = "morale-automation"
  description   = "Using the HTML5 Pulse Engine Javascript framework to create an interactive entertaining Chatty application. This will showcase state-of-the-art frontend interaction and websockets to have real time information shared across devices."
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "morale-automation_service-accounts-read-only" {
  repository = "${github_repository.morale-automation.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
