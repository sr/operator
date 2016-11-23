resource "github_repository" "kafka2rabbit" {
  name          = "kafka2rabbit"
  description   = "kafka storm topology for routing rabbit messages"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "kafka2rabbit_developers" {
  repository = "${github_repository.kafka2rabbit.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
