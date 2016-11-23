resource "github_repository" "pardot-child" {
  name          = "pardot-child"
  description   = "The new www.pardot.com wordpress theme!"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-child_service-accounts-read-only" {
  repository = "${github_repository.pardot-child.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
