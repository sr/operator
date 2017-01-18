resource "github_repository" "pardot-es-parser" {
  name          = "pardot-es-parser"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-es-parser_developers" {
  repository = "${github_repository.pardot-es-parser.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-es-parser_service-accounts-write-only" {
  repository = "${github_repository.pardot-es-parser.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-es-parser_engineering-managers" {
  repository = "${github_repository.pardot-es-parser.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "pardot-es-parser_site-reliability-engineers" {
  repository = "${github_repository.pardot-es-parser.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}
