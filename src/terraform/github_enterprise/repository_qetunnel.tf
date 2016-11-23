resource "github_repository" "qetunnel" {
  name          = "qetunnel"
  description   = "management of the sauce connect tunnel"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "qetunnel_ops" {
  repository = "${github_repository.qetunnel.name}"
  team_id    = "${github_team.ops.id}"
  permission = "pull"
}
