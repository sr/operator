resource "github_repository" "mesh" {
  name          = "mesh"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "mesh_developers" {
  repository = "${github_repository.mesh.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "mesh_service-accounts-read-only" {
  repository = "${github_repository.mesh.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "mesh_service-accounts-write-only" {
  repository = "${github_repository.mesh.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "mesh_service-accounts-administrators" {
  repository = "${github_repository.mesh.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}

resource "github_branch_protection" "mesh_master" {
  repository = "${github_repository.mesh.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}
