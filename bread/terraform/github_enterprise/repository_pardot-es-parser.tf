resource "github_repository" "pardot-es-parser" {
  name          = "pardot-es-parser"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "pardot-es-parser_master" {
  repository = "${github_repository.pardot-es-parser.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
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

resource "github_team_repository" "pardot-es-parser_service-accounts-administrators" {
  repository = "${github_repository.pardot-es-parser.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
