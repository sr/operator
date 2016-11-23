resource "github_repository" "mysql_gold_schema" {
  name          = "mysql_gold_schema"
  description   = "MySQL Gold Schema "
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "mysql_gold_schema_ops" {
  repository = "${github_repository.mysql_gold_schema.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "mysql_gold_schema_service-accounts-read-only" {
  repository = "${github_repository.mysql_gold_schema.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
