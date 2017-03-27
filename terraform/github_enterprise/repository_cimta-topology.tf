resource "github_repository" "cimta-topology" {
  name          = "cimta-topology"
  description   = "So I heard that you like touching campaigns..."
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "cimta-topology_master" {
  repository = "${github_repository.cimta-topology.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "cimta-topology_developers" {
  repository = "${github_repository.cimta-topology.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "cimta-topology_service-accounts-write-only" {
  repository = "${github_repository.cimta-topology.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "cimta-topology_service-accounts-administrators" {
  repository = "${github_repository.cimta-topology.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
