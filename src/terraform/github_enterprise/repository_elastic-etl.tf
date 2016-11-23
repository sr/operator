resource "github_repository" "elastic-etl" {
  name          = "elastic-etl"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "elastic-etl_developers" {
  repository = "${github_repository.elastic-etl.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "elastic-etl_service-accounts-read-only" {
  repository = "${github_repository.elastic-etl.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
