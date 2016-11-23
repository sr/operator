resource "github_repository" "statusboard" {
  name          = "statusboard"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "statusboard_service-accounts-read-only" {
  repository = "${github_repository.statusboard.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
