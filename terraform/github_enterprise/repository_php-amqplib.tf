resource "github_repository" "php-amqplib" {
  name          = "php-amqplib"
  description   = "AMQP library for PHP"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "php-amqplib_master" {
  repository = "${github_repository.php-amqplib.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "php-amqplib_developers" {
  repository = "${github_repository.php-amqplib.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "php-amqplib_service-accounts-read-only" {
  repository = "${github_repository.php-amqplib.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "php-amqplib_read-only-users" {
  repository = "${github_repository.php-amqplib.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "php-amqplib_service-accounts-write-only" {
  repository = "${github_repository.php-amqplib.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "php-amqplib_service-accounts-administrators" {
  repository = "${github_repository.php-amqplib.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
