resource "github_repository" "mesh-sync-package" {
  name          = "mesh-sync-package"
  description   = "Custom fields used to store Pi data as part of the Mesh sync."
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "mesh-sync-package_master" {
  repository = "${github_repository.mesh-sync-package.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "mesh-sync-package_service-accounts-write-only" {
  repository = "${github_repository.mesh-sync-package.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "mesh-sync-package_developers" {
  repository = "${github_repository.mesh-sync-package.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "mesh-sync-package_service-accounts-administrators" {
  repository = "${github_repository.mesh-sync-package.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
