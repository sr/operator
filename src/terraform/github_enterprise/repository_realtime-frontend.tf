resource "github_repository" "realtime-frontend" {
  name          = "realtime-frontend"
  description   = "Realtime frontend server"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "realtime-frontend_developers" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "realtime-frontend_service-accounts-write-only" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "realtime-frontend_service-accounts-read-only" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
