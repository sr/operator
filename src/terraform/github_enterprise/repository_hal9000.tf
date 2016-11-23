resource "github_repository" "hal9000" {
  name          = "hal9000"
  description   = "This repository has been moved to https://git.dev.pardot.com/Pardot/bread"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "hal9000_ops" {
  repository = "${github_repository.hal9000.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "hal9000_service-accounts-write-only" {
  repository = "${github_repository.hal9000.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
