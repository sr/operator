resource "github_repository" "datasets" {
  name          = "datasets"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "datasets_developers" {
  repository = "${github_repository.datasets.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "datasets_service-accounts-read-only" {
  repository = "${github_repository.datasets.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
