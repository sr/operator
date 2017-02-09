resource "github_repository" "pcswg" {
  name          = "pcswg"
  description   = "Pardot Code Standards Working Group"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pcswg_developers" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pcswg_engineering-managers" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "pcswg_site-reliability-engineers" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "pcswg_service-accounts-write-only" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pcswg_service-accounts-admins" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
