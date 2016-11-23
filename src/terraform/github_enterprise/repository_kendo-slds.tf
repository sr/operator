resource "github_repository" "kendo-slds" {
  name          = "kendo-slds"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "kendo-slds_developers" {
  repository = "${github_repository.kendo-slds.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
