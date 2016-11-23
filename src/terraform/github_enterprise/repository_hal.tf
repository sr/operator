resource "github_repository" "hal" {
  name          = "hal"
  description   = "DEPRECATED DEPRECATED DEPRECATED"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "hal_service-accounts-write-only" {
  repository = "${github_repository.hal.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "hal_service-accounts-read-only" {
  repository = "${github_repository.hal.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
