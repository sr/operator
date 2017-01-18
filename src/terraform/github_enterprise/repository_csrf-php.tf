resource "github_repository" "csrf-php" {
  name          = "csrf-php"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "csrf-php_developers" {
  repository = "${github_repository.csrf-php.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "csrf-php_service-accounts-read-only" {
  repository = "${github_repository.csrf-php.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "csrf-php_read-only-users" {
  repository = "${github_repository.csrf-php.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "csrf-php_service-accounts-write-only" {
  repository = "${github_repository.csrf-php.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}
