resource "github_repository" "cookbook-pardot_base" {
  name          = "cookbook-pardot_base"
  description   = "Home for pardotBase"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "cookbook-pardot_base_ops" {
  repository = "${github_repository.cookbook-pardot_base.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "cookbook-pardot_base_service-accounts-read-only" {
  repository = "${github_repository.cookbook-pardot_base.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
