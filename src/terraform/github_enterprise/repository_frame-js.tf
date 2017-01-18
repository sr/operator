resource "github_repository" "frame-js" {
  name          = "frame-js"
  description   = "an npm module that wraps postMessage"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "frame-js_developers" {
  repository = "${github_repository.frame-js.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "frame-js_service-accounts-write-only" {
  repository = "${github_repository.frame-js.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
