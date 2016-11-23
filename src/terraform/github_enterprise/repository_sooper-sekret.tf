resource "github_repository" "sooper-sekret" {
  name          = "sooper-sekret"
  description   = "For hack days!"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "sooper-sekret_service-accounts-read-only" {
  repository = "${github_repository.sooper-sekret.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
