resource "github_repository" "alert-dispatcher" {
  name          = "alert-dispatcher"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "alert-dispatcher_developers" {
  repository = "${github_repository.alert-dispatcher.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "alert-dispatcher_service-accounts-write-only" {
  repository = "${github_repository.alert-dispatcher.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "alert-dispatcher_service-accounts-administrators" {
  repository = "${github_repository.alert-dispatcher.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
