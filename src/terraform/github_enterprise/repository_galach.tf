resource "github_repository" "galach" {
  name          = "galach"
  description   = "Email shipping \"pipeline\" for use during SFDC integration - this project is intended to eventually produce a library to execute on Core."
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "galach_developers" {
  repository = "${github_repository.galach.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "galach_service-accounts-read-only" {
  repository = "${github_repository.galach.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
