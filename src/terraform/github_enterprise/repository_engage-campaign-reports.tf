resource "github_repository" "engage-campaign-reports" {
  name          = "engage-campaign-reports"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "engage-campaign-reports_developers" {
  repository = "${github_repository.engage-campaign-reports.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "engage-campaign-reports_service-accounts-write-only" {
  repository = "${github_repository.engage-campaign-reports.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "engage-campaign-reports_service-accounts-admins" {
  repository = "${github_repository.engage-campaign-reports.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}

resource "github_branch_protection" "engage-campaign-reports_master" {
  repository = "${github_repository.engage-campaign-reports.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}