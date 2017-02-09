resource "github_repository" "cimta-topology" {
  name          = "cimta-topology"
  description   = "So I heard that you like touching campaigns..."
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = true
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

resource "github_team_repository" "cimta-topology_engineering-managers" {
  repository = "${github_repository.cimta-topology.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "cimta-topology_site-reliability-engineers" {
  repository = "${github_repository.cimta-topology.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "cimta-topology_service-accounts-admins" {
  repository = "${github_repository.cimta-topology.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
