resource "github_repository" "vagrant-env" {
  name          = "vagrant-env"
  description   = "Vagrant Environment "
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "vagrant-env_developers" {
  repository = "${github_repository.vagrant-env.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-env_ops" {
  repository = "${github_repository.vagrant-env.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-env_service-accounts-read-only" {
  repository = "${github_repository.vagrant-env.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
