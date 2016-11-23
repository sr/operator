resource "github_repository" "canoe" {
  name          = "canoe"
  description   = "MOVED https://git.dev.pardot.com/Pardot/bread"
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "canoe_service-accounts-read-only" {
  repository = "${github_repository.canoe.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
