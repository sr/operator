resource "github_repository" "pd-homebrew" {
  name          = "pd-homebrew"
  description   = "Pardot Homebrew"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pd-homebrew_developers" {
  repository = "${github_repository.pd-homebrew.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
