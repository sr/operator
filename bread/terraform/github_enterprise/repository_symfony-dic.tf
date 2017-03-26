resource "github_repository" "symfony-dic" {
  name          = "symfony-dic"
  description   = "Symfony Dependency Injection"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "symfony-dic_master" {
  repository = "${github_repository.symfony-dic.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
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

resource "github_team_repository" "symfony-dic_service-accounts-write-only" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "symfony-dic_service-accounts-administrators" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
