resource "github_repository" "bamboo-configuration" {
  name          = "bamboo-configuration"
  description   = "Bamboo configuration for jobs and tasks"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
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
