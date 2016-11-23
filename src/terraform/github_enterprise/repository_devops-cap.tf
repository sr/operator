resource "github_repository" "devops-cap" {
  name          = "devops-cap"
  description   = "A Capistrano Repo of Useful Tasks"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "devops-cap_developers" {
  repository = "${github_repository.devops-cap.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "devops-cap_service-accounts-read-only" {
  repository = "${github_repository.devops-cap.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
