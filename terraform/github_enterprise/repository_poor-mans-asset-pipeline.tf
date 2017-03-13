resource "github_repository" "poor-mans-asset-pipeline" {
  name          = "poor-mans-asset-pipeline"
  description   = "A cheap knockoff the Rails asset pipeline"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "poor-mans-asset-pipeline_master" {
  repository = "${github_repository.poor-mans-asset-pipeline.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "poor-mans-asset-pipeline_developers" {
  repository = "${github_repository.poor-mans-asset-pipeline.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "poor-mans-asset-pipeline_service-accounts-write-only" {
  repository = "${github_repository.poor-mans-asset-pipeline.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "poor-mans-asset-pipeline_service-accounts-administrators" {
  repository = "${github_repository.poor-mans-asset-pipeline.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
