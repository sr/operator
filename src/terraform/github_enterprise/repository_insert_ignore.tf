resource "github_repository" "insert_ignore" {
  name          = "insert_ignore"
  description   = "The source for https://insert-ignore.herokuapp.com/"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "insert_ignore_developers" {
  repository = "${github_repository.insert_ignore.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "insert_ignore_engineering-managers" {
  repository = "${github_repository.insert_ignore.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "insert_ignore_site-reliability-engineers" {
  repository = "${github_repository.insert_ignore.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "insert_ignore_service-accounts-write-only" {
  repository = "${github_repository.insert_ignore.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "insert_ignore_service-accounts-admins" {
  repository = "${github_repository.insert_ignore.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
