resource "github_repository" "pcswg" {
  name          = "pcswg"
  description   = "Pardot Code Standards Working Group"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pcswg_developers" {
  repository = "${github_repository.pcswg.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}
