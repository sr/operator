resource "github_repository" "bamboo-configuration" {
  name          = "bamboo-configuration"
  description   = "Bamboo configuration for jobs and tasks"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "bamboo-configuration_master" {
  repository = "${github_repository.bamboo-configuration.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "bamboo-configuration_developers" {
  repository = "${github_repository.bamboo-configuration.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-configuration_service-accounts-read-only" {
  repository = "${github_repository.bamboo-configuration.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "bamboo-configuration_service-accounts-write-only" {
  repository = "${github_repository.bamboo-configuration.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-configuration_service-accounts-administrators" {
  repository = "${github_repository.bamboo-configuration.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}

resource "github_branch_protection" "bamboo-configuration_develop" {
  repository = "${github_repository.bamboo-configuration.name}"
  branch     = "develop"
}
