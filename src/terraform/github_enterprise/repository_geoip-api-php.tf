resource "github_repository" "geoip-api-php" {
  name          = "geoip-api-php"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "geoip-api-php_developers" {
  repository = "${github_repository.geoip-api-php.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "geoip-api-php_service-accounts-write-only" {
  repository = "${github_repository.geoip-api-php.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "geoip-api-php_read-only-users" {
  repository = "${github_repository.geoip-api-php.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "geoip-api-php_site-reliability-engineers" {
  repository = "${github_repository.geoip-api-php.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "geoip-api-php_engineering-managers" {
  repository = "${github_repository.geoip-api-php.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}
