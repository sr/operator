resource "github_repository" "pardot-explorer" {
  name          = "pardot-explorer"
  description   = "MOVED https://git.dev.pardot.com/Pardot/bread"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-explorer_service-accounts-read-only" {
  repository = "${github_repository.pardot-explorer.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
