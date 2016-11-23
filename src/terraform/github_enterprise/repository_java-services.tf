resource "github_repository" "java-services" {
  name          = "java-services"
  description   = "An api layer for Visitor information"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "java-services_developers" {
  repository = "${github_repository.java-services.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "java-services_service-accounts-write-only" {
  repository = "${github_repository.java-services.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "java-services_service-accounts-read-only" {
  repository = "${github_repository.java-services.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "java-services_ops" {
  repository = "${github_repository.java-services.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
