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
