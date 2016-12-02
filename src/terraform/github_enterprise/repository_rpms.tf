resource "github_repository" "rpms" {
  name          = "rpms"
  description   = "A buildroot for building custom RPMs"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "rpms_developers" {
  repository = "${github_repository.rpms.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
