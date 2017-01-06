resource "github_repository" "salesforce-actions-topologies" {
  name          = "salesforce-actions-topologies"
  description   = "Blue Mesh: Codebase for pushing Blue-Steel metrics into NA5"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "salesforce-actions-topologies_developers" {
  repository = "${github_repository.salesforce-actions-topologies.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "salesforce-actions-topologies_service-accounts-write-only" {
  repository = "${github_repository.salesforce-actions-topologies.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_branch_protection" "salesforce-actions-topologies_master" {
  repository = "${github_repository.salesforce-actions-topologies.name}"
  branch     = "master"

  include_admins = true
  strict         = false
  contexts       = ["Test Jobs"]
}
