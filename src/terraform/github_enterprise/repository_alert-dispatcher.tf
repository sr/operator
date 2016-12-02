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