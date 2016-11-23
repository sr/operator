resource "github_repository" "jmeter-timing" {
  name          = "jmeter-timing"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "jmeter-timing_developers" {
  repository = "${github_repository.jmeter-timing.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "jmeter-timing_service-accounts-read-only" {
  repository = "${github_repository.jmeter-timing.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
