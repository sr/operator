resource "github_repository" "kb-articles" {
  name          = "kb-articles"
  description   = "Knowledge Base Articles"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "kb-articles_master" {
  repository = "${github_repository.kb-articles.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "kb-articles_documentation-editors" {
  repository = "${github_repository.kb-articles.name}"
  team_id    = "${github_team.documentation-editors.id}"
  permission = "push"
}

resource "github_team_repository" "kb-articles_developers" {
  repository = "${github_repository.kb-articles.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "kb-articles_service-accounts-read-only" {
  repository = "${github_repository.kb-articles.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "kb-articles_service-accounts-write-only" {
  repository = "${github_repository.kb-articles.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "kb-articles_service-accounts-administrators" {
  repository = "${github_repository.kb-articles.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
