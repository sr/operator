resource "github_repository" "pardot-storm-example" {
  name          = "pardot-storm-example"
  description   = "Want an Example to get started with Pardot Storm?"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-storm-example_developers" {
  repository = "${github_repository.pardot-storm-example.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
