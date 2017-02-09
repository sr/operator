resource "github_repository" "swiftmailer" {
  name          = "swiftmailer"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
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

resource "github_team_repository" "swiftmailer_engineering-managers" {
  repository = "${github_repository.swiftmailer.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "swiftmailer_site-reliability-engineers" {
  repository = "${github_repository.swiftmailer.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "swiftmailer_service-accounts-admins" {
  repository = "${github_repository.swiftmailer.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
