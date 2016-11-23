resource "github_repository" "pardot_canoe" {
  name          = "pardot_canoe"
  description   = "Temporary repository for working on pardot_canoe cookbook creation"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot_canoe_ops" {
  repository = "${github_repository.pardot_canoe.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "pardot_canoe_service-accounts-read-only" {
  repository = "${github_repository.pardot_canoe.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
