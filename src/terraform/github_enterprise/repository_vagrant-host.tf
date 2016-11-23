resource "github_repository" "vagrant-host" {
  name          = "vagrant-host"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "vagrant-host_developers" {
  repository = "${github_repository.vagrant-host.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-host_service-accounts-read-only" {
  repository = "${github_repository.vagrant-host.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
