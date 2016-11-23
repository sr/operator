resource "github_repository" "pro-services" {
  name          = "pro-services"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pro-services_service-accounts-read-only" {
  repository = "${github_repository.pro-services.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
