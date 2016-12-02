resource "github_repository" "insert_ignore" {
  name          = "insert_ignore"
  description   = "The source for https://insert-ignore.herokuapp.com/"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "insert_ignore_developers" {
  repository = "${github_repository.insert_ignore.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
