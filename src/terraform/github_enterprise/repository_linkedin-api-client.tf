resource "github_repository" "linkedin-api-client" {
  name          = "linkedin-api-client"
  description   = "Its a client. For the \"in\" links."
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "linkedin-api-client_developers" {
  repository = "${github_repository.linkedin-api-client.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "linkedin-api-client_service-accounts-read-only" {
  repository = "${github_repository.linkedin-api-client.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
