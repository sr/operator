resource "github_repository" "cookbook-repos" {
  name          = "cookbook-repos"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "cookbook-repos_developers" {
  repository = "${github_repository.cookbook-repos.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "cookbook-repos_service-accounts-read-only" {
  repository = "${github_repository.cookbook-repos.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
