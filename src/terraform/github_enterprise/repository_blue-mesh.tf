resource "github_repository" "blue-mesh" {
  name          = "blue-mesh"
  description   = "Blue Mesh: Codebase for pushing Blue-Steel metrics into NA5"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "blue-mesh_developers" {
  repository = "${github_repository.blue-mesh.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "blue-mesh_service-accounts-write-only" {
  repository = "${github_repository.blue-mesh.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "blue-mesh_engineering-managers" {
  repository = "${github_repository.blue-mesh.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "blue-mesh_site-reliability-engineers" {
  repository = "${github_repository.blue-mesh.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_branch_protection" "blue-mesh_master" {
  repository = "${github_repository.blue-mesh.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}
