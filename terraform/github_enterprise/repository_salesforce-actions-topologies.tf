resource "github_repository" "salesforce-actions-topologies" {
  name          = "salesforce-actions-topologies"
  description   = "3rd Party Actions Storm Topology"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_branch_protection" "salesforce-actions-topologies_master" {
  repository = "${github_repository.salesforce-actions-topologies.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
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

resource "github_team_repository" "salesforce-actions-topologies_service-accounts-administrators" {
  repository = "${github_repository.salesforce-actions-topologies.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
