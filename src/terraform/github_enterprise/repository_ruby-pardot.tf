resource "github_repository" "ruby-pardot" {
  name          = "ruby-pardot"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "ruby-pardot_ops" {
  repository = "${github_repository.ruby-pardot.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
