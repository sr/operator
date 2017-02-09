resource "github_repository" "php-amqplib2" {
  name          = "php-amqplib2"
  description   = "AMQP library for PHP"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "php-amqplib2_developers" {
  repository = "${github_repository.php-amqplib2.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "php-amqplib2_service-accounts-write-only" {
  repository = "${github_repository.php-amqplib2.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "php-amqplib2_service-accounts-administrators" {
  repository = "${github_repository.php-amqplib2.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
