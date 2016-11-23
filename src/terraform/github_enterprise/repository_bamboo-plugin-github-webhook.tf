resource "github_repository" "bamboo-plugin-github-webhook" {
  name          = "bamboo-plugin-github-webhook"
  description   = "GitHub webhook trigger for Bamboo"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "bamboo-plugin-github-webhook_ops" {
  repository = "${github_repository.bamboo-plugin-github-webhook.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-plugin-github-webhook_developers" {
  repository = "${github_repository.bamboo-plugin-github-webhook.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
