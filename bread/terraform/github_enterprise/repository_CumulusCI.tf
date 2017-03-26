resource "github_repository" "CumulusCI" {
  name          = "CumulusCI"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "CumulusCI_master" {
  repository = "${github_repository.CumulusCI.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "CumulusCI_service-accounts-write-only" {
  repository = "${github_repository.CumulusCI.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "CumulusCI_service-accounts-administrators" {
  repository = "${github_repository.CumulusCI.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
