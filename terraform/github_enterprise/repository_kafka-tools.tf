resource "github_repository" "kafka-tools" {
  name          = "kafka-tools"
  description   = "Various tools built around or ontop of Kafka"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "kafka-tools_master" {
  repository = "${github_repository.kafka-tools.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "kafka-tools_developers" {
  repository = "${github_repository.kafka-tools.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "kafka-tools_service-accounts-write-only" {
  repository = "${github_repository.kafka-tools.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "kafka-tools_service-accounts-administrators" {
  repository = "${github_repository.kafka-tools.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
