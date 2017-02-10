resource "github_repository" "docker-library" {
  name          = "docker-library"
  description   = "Docker base images for our containerized environments"
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
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

resource "github_team_repository" "docker-library_service-accounts-administrators" {
  repository = "${github_repository.docker-library.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}

resource "github_branch_protection" "docker-library_master" {
  repository = "${github_repository.docker-library.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}
