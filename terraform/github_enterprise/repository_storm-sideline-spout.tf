resource "github_repository" "storm-sideline-spout" {
  name          = "storm-sideline-spout"
  description   = "A Kafka (0.10.0.x) based spout for Apache Storm (1.0.x) that provides the ability to dynamically "sideline" or skip specific messages to be replayed at a later time based on a set of filter criteria."
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "storm-sideline-spout_developers" {
  repository = "${github_repository.storm-sideline-spout.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
