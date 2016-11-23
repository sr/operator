resource "github_repository" "pull_agent" {
  name          = "pull_agent"
  description   = "MOVED https://git.dev.pardot.com/Pardot/bread"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pull_agent_ops" {
  repository = "${github_repository.pull_agent.name}"
  team_id    = "${github_team.ops.id}"
  permission = "pull"
}
