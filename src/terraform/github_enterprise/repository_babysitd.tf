resource "github_repository" "babysitd" {
  name          = "babysitd"
  description   = "The dynamic IP gateway monitor"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "babysitd_developers" {
  repository = "${github_repository.babysitd.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "babysitd_site-reliability-engineers" {
  repository = "${github_repository.babysitd.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "babysitd_engineering-managers" {
  repository = "${github_repository.babysitd.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "babysitd_service-accounts-write-only" {
  repository = "${github_repository.babysitd.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "babysitd_service-accounts-admins" {
  repository = "${github_repository.babysitd.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
