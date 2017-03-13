resource "github_repository" "geoip-api-php" {
  name          = "geoip-api-php"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "geoip-api-php_master" {
  repository = "${github_repository.geoip-api-php.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
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

resource "github_team_repository" "geoip-api-php_service-accounts-administrators" {
  repository = "${github_repository.geoip-api-php.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
