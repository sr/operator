resource "github_repository" "pardot-demo-org-visualforce" {
  name          = "pardot-demo-org-visualforce"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-demo-org-visualforce_developers" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-demo-org-visualforce_engineering-managers" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "pardot-demo-org-visualforce_site-reliability-engineers" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "pardot-demo-org-visualforce_service-accounts-write-only" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-demo-org-visualforce_service-accounts-admins" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
