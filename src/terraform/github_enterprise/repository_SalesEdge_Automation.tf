resource "github_repository" "SalesEdge_Automation" {
  name          = "SalesEdge_Automation"
  description   = "Browser automation using ruby+watir framework"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "SalesEdge_Automation_service-accounts-read-only" {
  repository = "${github_repository.SalesEdge_Automation.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
