resource "github_repository" "ops-stacki" {
  name          = "ops-stacki"
  description   = "Repository for tracking changes to new provisioning tool / yum repository for Terminus"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "ops-stacki_ops" {
  repository = "${github_repository.ops-stacki.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "ops-stacki_engineering-managers" {
  repository = "${github_repository.ops-stacki.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "ops-stacki_site-reliability-engineers" {
  repository = "${github_repository.ops-stacki.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "ops-stacki_service-accounts-write-only" {
  repository = "${github_repository.ops-stacki.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "ops-stacki_service-accounts-admins" {
  repository = "${github_repository.ops-stacki.name}"
  team_id    = "${github_team.service-accounts-admins.id}"
  permission = "admin"
}
