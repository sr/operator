resource "github_repository" "gcreader" {
  name          = "gcreader"
  description   = "Quick and dirty scripts for java garbage collection parsing and analysis"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "gcreader_ops" {
  repository = "${github_repository.gcreader.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "gcreader_service-accounts-read-only" {
  repository = "${github_repository.gcreader.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
