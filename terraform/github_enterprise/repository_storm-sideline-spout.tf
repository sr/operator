resource "github_repository" "storm-sideline-spout" {
  name          = "storm-sideline-spout"
  description   = "A Kafka (0.10.0.x) based spout for Apache Storm (1.0.x) that provides the ability to dynamically 'sideline' or skip specific messages to be replayed at a later time based on a set of filter criteria."
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_branch_protection" "storm-sideline-spout" {
  repository = "${github_repository.storm-sideline-spout.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "storm-sideline-spout_developers" {
  repository = "${github_repository.storm-sideline-spout.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "storm-sideline-spout_service-accounts-write-only" {
  repository = "${github_repository.storm-sideline-spout.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "storm-sideline-spout_service-accounts-read-only" {
  repository = "${github_repository.storm-sideline-spout.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "storm-sideline-spout_service-accounts-administrators" {
  repository = "${github_repository.storm-sideline-spout.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
