resource "github_repository" "library" {
  name          = "library"
  description   = "pattern library and view mapping"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "library_developers" {
  repository = "${github_repository.library.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "library_service-accounts-write-only" {
  repository = "${github_repository.library.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "library_service-accounts-read-only" {
  repository = "${github_repository.library.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
