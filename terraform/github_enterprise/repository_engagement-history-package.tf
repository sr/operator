resource "github_repository" "engagement-history-package" {
  name          = "engagement-history-package"
  description   = "Engagement History"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = false
}

resource "github_branch_protection" "engagement-history-package_master" {
  repository = "${github_repository.engagement-history-package.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "engagement-history-package_developers" {
  repository = "${github_repository.engagement-history-package.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "engagement-history-package_service-accounts-read-only" {
  repository = "${github_repository.engagement-history-package.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "engagement-history-package_service-accounts-write-only" {
  repository = "${github_repository.engagement-history-package.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "engagement-history-package_service-accounts-administrators" {
  repository = "${github_repository.engagement-history-package.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
