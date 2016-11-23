resource "github_repository" "supportbot-zendesk" {
  name          = "supportbot-zendesk"
  description   = "SupportBot Zendesk App"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "supportbot-zendesk_service-accounts-read-only" {
  repository = "${github_repository.supportbot-zendesk.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
