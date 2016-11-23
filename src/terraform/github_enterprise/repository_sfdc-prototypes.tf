resource "github_repository" "sfdc-prototypes" {
  name          = "sfdc-prototypes"
  description   = "The villain of prototype repositories, doing programming evil for the greater good"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "sfdc-prototypes_developers" {
  repository = "${github_repository.sfdc-prototypes.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "sfdc-prototypes_service-accounts-read-only" {
  repository = "${github_repository.sfdc-prototypes.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
