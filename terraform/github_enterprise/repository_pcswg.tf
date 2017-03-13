resource "github_repository" "pcswg" {
  name          = "pcswg"
  description   = "Pardot Code Standards Working Group"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "pcswg_master" {
  repository = "${github_repository.pcswg.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "pcswg_developers" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pcswg_service-accounts-write-only" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pcswg_service-accounts-administrators" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
