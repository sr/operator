resource "github_repository" "bamboo-elastic-instance" {
  name          = "bamboo-elastic-instance"
  description   = "Configuration scripts for Pardot bamboo continuous integration agents"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "bamboo-elastic-instance_developers" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-elastic-instance_service-accounts-write-only" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-elastic-instance_service-accounts-read-only" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "bamboo-elastic-instance_site-reliability-engineers" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "bamboo-elastic-instance_engineering-managers" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "bamboo-elastic-instance_service-accounts-admins" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}

resource "github_branch_protection" "bamboo-elastic-instance_develop" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  branch     = "develop"
}
