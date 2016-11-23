resource "github_repository" "closed-loop-reporting" {
  name          = "closed-loop-reporting"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "closed-loop-reporting_service-accounts-read-only" {
  repository = "${github_repository.closed-loop-reporting.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
