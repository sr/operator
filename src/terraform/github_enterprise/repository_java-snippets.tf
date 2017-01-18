resource "github_repository" "java-snippets" {
  name          = "java-snippets"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "java-snippets_developers" {
  repository = "${github_repository.java-snippets.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "java-snippets_service-accounts-read-only" {
  repository = "${github_repository.java-snippets.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "java-snippets_site-reliability-engineers" {
  repository = "${github_repository.java-snippets.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "java-snippets_engineering-managers" {
  repository = "${github_repository.java-snippets.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}
