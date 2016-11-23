resource "github_repository" "bamboo-plugin-github-enterprise" {
  name          = "bamboo-plugin-github-enterprise"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "bamboo-plugin-github-enterprise_ops" {
  repository = "${github_repository.bamboo-plugin-github-enterprise.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-plugin-github-enterprise_developers" {
  repository = "${github_repository.bamboo-plugin-github-enterprise.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
