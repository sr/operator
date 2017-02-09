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

resource "github_team_repository" "rpms_service-accounts-write-only" {
  repository = "${github_repository.rpms.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "rpms_service-accounts-administrators" {
  repository = "${github_repository.rpms.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
