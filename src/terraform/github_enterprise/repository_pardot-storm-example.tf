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

resource "github_team_repository" "pardot-storm-example_service-accounts-write-only" {
  repository = "${github_repository.pardot-storm-example.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-storm-example_service-accounts-administrators" {
  repository = "${github_repository.pardot-storm-example.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
