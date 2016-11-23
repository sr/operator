resource "github_repository" "enola" {
  name          = "enola"
  description   = "Next gen drip builder / nurture composer"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "enola_developers" {
  repository = "${github_repository.enola.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "enola_service-accounts-read-only" {
  repository = "${github_repository.enola.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
