resource "github_repository" "pardot-maven-artifacts" {
  name          = "pardot-maven-artifacts"
  description   = "Maven Artifacts for Pardot Java projects"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-maven-artifacts_developers" {
  repository = "${github_repository.pardot-maven-artifacts.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-maven-artifacts_service-accounts-read-only" {
  repository = "${github_repository.pardot-maven-artifacts.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
