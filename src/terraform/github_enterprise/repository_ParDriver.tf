resource "github_repository" "ParDriver" {
  name          = "ParDriver"
  description   = "logintest"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "ParDriver_developers" {
  repository = "${github_repository.ParDriver.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
