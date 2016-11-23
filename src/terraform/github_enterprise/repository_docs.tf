resource "github_repository" "docs" {
  name          = "docs"
  description   = "The Documentations"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "docs_developers" {
  repository = "${github_repository.docs.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "docs_ops" {
  repository = "${github_repository.docs.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "docs_service-accounts-read-only" {
  repository = "${github_repository.docs.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
