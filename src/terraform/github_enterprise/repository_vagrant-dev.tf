resource "github_repository" "vagrant-dev" {
  name          = "vagrant-dev"
  description   = "Pardot's Vagrant setup"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "vagrant-dev_developers" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-dev_ops" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-dev_service-accounts-read-only" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "vagrant-dev_tier-2-support" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.tier-2-support.id}"
  permission = "push"
}
