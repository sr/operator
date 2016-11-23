resource "github_repository" "symfony" {
  name          = "symfony"
  description   = "Pardot fork of symfony"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "symfony_service-accounts-read-only" {
  repository = "${github_repository.symfony.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
