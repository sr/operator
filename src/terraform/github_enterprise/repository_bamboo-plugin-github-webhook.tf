resource "github_repository" "bamboo-plugin-github-webhook" {
  name          = "bamboo-plugin-github-webhook"
  description   = "GitHub webhook trigger for Bamboo"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "bamboo-plugin-github-webhook_developers" {
  repository = "${github_repository.bamboo-plugin-github-webhook.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-plugin-github-webhook_site-reliability-engineers" {
  repository = "${github_repository.bamboo-plugin-github-webhook.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "bamboo-plugin-github-webhook_engineering-managers" {
  repository = "${github_repository.bamboo-plugin-github-webhook.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "bamboo-plugin-github-webhook_service-accounts-write-only" {
  repository = "${github_repository.bamboo-plugin-github-webhook.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}