resource "github_repository" "all-the-bacon" {
  name          = "all-the-bacon"
  description   = "Scratch space repo for Mike Lockhart"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "all-the-bacon_service-accounts-read-only" {
  repository = "${github_repository.all-the-bacon.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "all-the-bacon_developers" {
  repository = "${github_repository.all-the-bacon.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "all-the-bacon_core-production-security" {
  repository = "${github_repository.all-the-bacon.name}"
  team_id    = "${github_team.core-production-security.id}"
  permission = "pull"
}

resource "github_team_repository" "all-the-bacon_service-accounts-write-only" {
  repository = "${github_repository.all-the-bacon.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
