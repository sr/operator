resource "github_repository" "pd-homebrew-php" {
  name          = "pd-homebrew-php"
  description   = "We need to temporarily mirror the php homebrew repository because the way that homebrew does dependency management is incompatible with us overriding the php70 recipe. Having this in it's own repository instead of the pd-homebrew repository will allow us to keep the recipes (like rmux) that we need to survive once our fixes are more mainstream."
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pd-homebrew-php_developers" {
  repository = "${github_repository.pd-homebrew-php.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pd-homebrew-php_engineering-managers" {
  repository = "${github_repository.pd-homebrew-php.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "pd-homebrew-php_site-reliability-engineers" {
  repository = "${github_repository.pd-homebrew-php.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "pd-homebrew-php_service-accounts-write-only" {
  repository = "${github_repository.pd-homebrew-php.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pd-homebrew-php_service-accounts-admins" {
  repository = "${github_repository.pd-homebrew-php.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
