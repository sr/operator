resource "github_repository" "kafka-tools" {
  name          = "kafka-tools"
  description   = "Various tools built around or ontop of Kafka"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "kafka-tools_developers" {
  repository = "${github_repository.kafka-tools.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "kafka-tools_site-reliability-engineers" {
  repository = "${github_repository.kafka-tools.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "kafka-tools_engineering-managers" {
  repository = "${github_repository.kafka-tools.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}
