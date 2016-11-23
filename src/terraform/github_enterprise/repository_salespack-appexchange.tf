resource "github_repository" "salespack-appexchange" {
  name          = "salespack-appexchange"
  description   = "App exchange package for the product formerly known as salespack"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "salespack-appexchange_developers" {
  repository = "${github_repository.salespack-appexchange.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "salespack-appexchange_service-accounts-write-only" {
  repository = "${github_repository.salespack-appexchange.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "salespack-appexchange_service-accounts-read-only" {
  repository = "${github_repository.salespack-appexchange.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
