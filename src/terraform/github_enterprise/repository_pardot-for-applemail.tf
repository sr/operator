resource "github_repository" "pardot-for-applemail" {
  name          = "pardot-for-applemail"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-for-applemail_developers" {
  repository = "${github_repository.pardot-for-applemail.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-for-applemail_service-accounts-read-only" {
  repository = "${github_repository.pardot-for-applemail.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
