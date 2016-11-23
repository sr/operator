resource "github_repository" "prodbot" {
  name          = "prodbot"
  description   = "Prodbot has been retired. Please use HAL9000 instead."
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "prodbot_ops" {
  repository = "${github_repository.prodbot.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
