resource "github_repository" "cookbook-pardot_miki" {
  name          = "cookbook-pardot_miki"
  description   = "Home of chef recipes for thumbnail service: Miki (mee kee)"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "cookbook-pardot_miki_ops" {
  repository = "${github_repository.cookbook-pardot_miki.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "cookbook-pardot_miki_service-accounts-read-only" {
  repository = "${github_repository.cookbook-pardot_miki.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
