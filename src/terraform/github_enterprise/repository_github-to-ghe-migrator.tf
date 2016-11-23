resource "github_repository" "github-to-ghe-migrator" {
  name          = "github-to-ghe-migrator"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "github-to-ghe-migrator_developers" {
  repository = "${github_repository.github-to-ghe-migrator.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
