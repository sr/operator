resource "github_repository" "chef" {
  name          = "chef"
  description   = "Chef"
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "chef_ops" {
  repository = "${github_repository.chef.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "chef_service-accounts-write-only" {
  repository = "${github_repository.chef.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "chef_service-accounts-read-only" {
  repository = "${github_repository.chef.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "chef_developers" {
  repository = "${github_repository.chef.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "chef_site-reliability-engineers" {
  repository = "${github_repository.chef.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "chef_engineering-managers" {
  repository = "${github_repository.chef.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "chef_service-accounts-admins" {
  repository = "${github_repository.chef.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}

resource "github_branch_protection" "chef_master" {
  repository = "${github_repository.chef.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}
