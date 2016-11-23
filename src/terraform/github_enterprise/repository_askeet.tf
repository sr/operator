resource "github_repository" "askeet" {
  name          = "askeet"
  description   = "Repo for new developers to learn about symfony 1.x"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "askeet_developers" {
  repository = "${github_repository.askeet.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "askeet_service-accounts-read-only" {
  repository = "${github_repository.askeet.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
