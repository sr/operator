resource "github_repository" "kendo-slds" {
  name          = "kendo-slds"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "kendo-slds_master" {
  repository = "${github_repository.kendo-slds.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "kendo-slds_developers" {
  repository = "${github_repository.kendo-slds.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "kendo-slds_service-accounts-write-only" {
  repository = "${github_repository.kendo-slds.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "kendo-slds_service-accounts-administrators" {
  repository = "${github_repository.kendo-slds.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
