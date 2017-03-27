resource "github_repository" "pardot-demo-org-visualforce" {
  name          = "pardot-demo-org-visualforce"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "pardot-demo-org-visualforce_master" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "pardot-demo-org-visualforce_developers" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-demo-org-visualforce_service-accounts-write-only" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-demo-org-visualforce_service-accounts-administrators" {
  repository = "${github_repository.pardot-demo-org-visualforce.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
