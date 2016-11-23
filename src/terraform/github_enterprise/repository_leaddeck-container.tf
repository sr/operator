resource "github_repository" "leaddeck-container" {
  name          = "leaddeck-container"
  description   = "Container App for LeadDeck"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "leaddeck-container_developers" {
  repository = "${github_repository.leaddeck-container.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "leaddeck-container_service-accounts-read-only" {
  repository = "${github_repository.leaddeck-container.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
