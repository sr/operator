resource "github_repository" "babysitd" {
  name          = "babysitd"
  description   = "The dynamic IP gateway monitor"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "babysitd_developers" {
  repository = "${github_repository.babysitd.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
