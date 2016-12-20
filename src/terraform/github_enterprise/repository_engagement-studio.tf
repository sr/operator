resource "github_repository" "engagement-studio" {
  name          = "engagement-studio"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "engagement-studio_developers" {
  repository = "${github_repository.engagement-studio.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "engagement-studio_service-accounts-write-only" {
  repository = "${github_repository.engagement-studio.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_branch_protection" "engagement-studio_master" {
  repository = "${github_repository.engagement-studio.name}"
  branch     = "master"
}
