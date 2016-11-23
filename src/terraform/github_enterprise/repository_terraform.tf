resource "github_repository" "terraform" {
  name          = "terraform"
  description   = "MOVED https://git.dev.pardot.com/Pardot/bread"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "terraform_ops" {
  repository = "${github_repository.terraform.name}"
  team_id    = "${github_team.ops.id}"
  permission = "pull"
}
