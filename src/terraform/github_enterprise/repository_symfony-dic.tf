resource "github_repository" "symfony-dic" {
  name          = "symfony-dic"
  description   = "Symfony Dependency Injection"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "symfony-dic_developers" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "symfony-dic_service-accounts-read-only" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "symfony-dic_engineering-managers" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "symfony-dic_site-reliability-engineers" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "symfony-dic_service-accounts-write-only" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "symfony-dic_service-accounts-admins" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
