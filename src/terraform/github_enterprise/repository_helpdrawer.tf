resource "github_repository" "helpdrawer" {
  name          = "helpdrawer"
  description   = "The mini-app that generates the helpdrawer contents"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "helpdrawer_developers" {
  repository = "${github_repository.helpdrawer.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "helpdrawer_service-accounts-read-only" {
  repository = "${github_repository.helpdrawer.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
