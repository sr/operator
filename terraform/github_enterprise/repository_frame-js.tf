resource "github_repository" "frame-js" {
  name          = "frame-js"
  description   = "an npm module that wraps postMessage"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "frame-js_master" {
  repository = "${github_repository.frame-js.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
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

resource "github_team_repository" "frame-js_service-accounts-administrators" {
  repository = "${github_repository.frame-js.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
