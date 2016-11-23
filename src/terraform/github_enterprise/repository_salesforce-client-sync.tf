resource "github_repository" "salesforce-client-sync" {
  name          = "salesforce-client-sync"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "salesforce-client-sync_developers" {
  repository = "${github_repository.salesforce-client-sync.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "salesforce-client-sync_service-accounts-read-only" {
  repository = "${github_repository.salesforce-client-sync.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
