resource "github_repository" "vagrant-askeet" {
  name          = "vagrant-askeet"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "vagrant-askeet_developers" {
  repository = "${github_repository.vagrant-askeet.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-askeet_service-accounts-read-only" {
  repository = "${github_repository.vagrant-askeet.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
