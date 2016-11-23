resource "github_repository" "xymon" {
  name          = "xymon"
  description   = "Xymon Configuration files"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "xymon_ops" {
  repository = "${github_repository.xymon.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "xymon_service-accounts-read-only" {
  repository = "${github_repository.xymon.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
