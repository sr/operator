resource "github_repository" "event-service-bus" {
  name          = "event-service-bus"
  description   = "Standalone Salesforce Engage event service bus"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "event-service-bus_service-accounts-read-only" {
  repository = "${github_repository.event-service-bus.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
