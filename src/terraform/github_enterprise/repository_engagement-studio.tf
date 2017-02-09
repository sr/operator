resource "github_repository" "engagement-studio" {
  name          = "engagement-studio"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "engagement-studio_developers" {
  repository = "${github_repository.engagement-studio.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "engagement-studio_service-accounts-write-only" {
  repository = "${github_repository.engagement-studio.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "engagement-studio_site-reliability-engineers" {
  repository = "${github_repository.engagement-studio.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "engagement-studio_engineering-managers" {
  repository = "${github_repository.engagement-studio.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "engagement-studio_service-accounts-admins" {
  repository = "${github_repository.engagement-studio.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}

resource "github_branch_protection" "engagement-studio_master" {
  repository = "${github_repository.engagement-studio.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}
