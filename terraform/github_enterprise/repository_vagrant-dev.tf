resource "github_repository" "vagrant-dev" {
  name          = "vagrant-dev"
  description   = "Pardot's Vagrant setup"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "vagrant-dev_master" {
  repository = "${github_repository.vagrant-dev.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "vagrant-dev_developers" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.developers.id}"
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

resource "github_team_repository" "vagrant-dev_read-only-users" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "vagrant-dev_service-accounts-write-only" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-dev_service-accounts-administrators" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
