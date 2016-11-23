resource "github_repository" "java-services-tools" {
  name          = "java-services-tools"
  description   = "A set of shell scripts that make managing pardot java services machines less painful."
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "java-services-tools_developers" {
  repository = "${github_repository.java-services-tools.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "java-services-tools_service-accounts-read-only" {
  repository = "${github_repository.java-services-tools.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
