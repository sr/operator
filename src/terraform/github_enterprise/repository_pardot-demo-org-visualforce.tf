resource "github_repository" "pardot-demo-org-visualforce" {
  name          = "pardot-demo-org-visualforce"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-demo-org-visualforce_developers" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
