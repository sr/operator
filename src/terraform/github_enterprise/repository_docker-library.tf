resource "github_repository" "docker-library" {
  name          = "docker-library"
  description   = "Docker base images for our containerized environments"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "docker-library_developers" {
  repository = "${github_repository.docker-library.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "docker-library_service-accounts-write-only" {
  repository = "${github_repository.docker-library.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "docker-library_site-reliability-engineers" {
  repository = "${github_repository.docker-library.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "docker-library_engineering-managers" {
  repository = "${github_repository.docker-library.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}
