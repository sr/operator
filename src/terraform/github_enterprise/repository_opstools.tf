resource "github_repository" "opstools" {
  name          = "opstools"
  description   = "Operations Toolbox"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "opstools_ops" {
  repository = "${github_repository.opstools.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "opstools_service-accounts-read-only" {
  repository = "${github_repository.opstools.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
