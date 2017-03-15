resource "github_repository" "swiftmailer" {
  name          = "swiftmailer"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "swiftmailer_master" {
  repository = "${github_repository.swiftmailer.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "swiftmailer_developers" {
  repository = "${github_repository.swiftmailer.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "swiftmailer_service-accounts-write-only" {
  repository = "${github_repository.swiftmailer.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "swiftmailer_read-only-users" {
  repository = "${github_repository.swiftmailer.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "swiftmailer_service-accounts-administrators" {
  repository = "${github_repository.swiftmailer.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
