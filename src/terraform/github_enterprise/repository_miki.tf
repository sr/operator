resource "github_repository" "miki" {
  name          = "miki"
  description   = "Thumbnail service"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "miki_developers" {
  repository = "${github_repository.miki.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "miki_service-accounts-read-only" {
  repository = "${github_repository.miki.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
