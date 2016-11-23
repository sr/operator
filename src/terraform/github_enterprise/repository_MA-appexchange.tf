resource "github_repository" "MA-appexchange" {
  name          = "MA-appexchange"
  description   = "A blatant ripoff of Salespack's appexchange code"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "MA-appexchange_developers" {
  repository = "${github_repository.MA-appexchange.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "MA-appexchange_ops" {
  repository = "${github_repository.MA-appexchange.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "MA-appexchange_service-accounts-read-only" {
  repository = "${github_repository.MA-appexchange.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
