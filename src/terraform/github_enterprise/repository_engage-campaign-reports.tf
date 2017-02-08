resource "github_repository" "engage-campaign-reports" {
  name          = "engage-campaign-reports"
  description   = "Engage Campaign Reports"
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

resource "github_team_repository" "engage-campaign-reports_read-only-users" {
  repository = "${github_repository.engage-campaign-reports.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "engage-campaign-reports_engineering-managers" {
  repository = "${github_repository.engage-campaign-reports.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "engage-campaign-reports_site-reliability-engineers" {
  repository = "${github_repository.engage-campaign-reports.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "engage-campaign-reports_service-accounts-write-only" {
  repository = "${github_repository.engage-campaign-reports.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
