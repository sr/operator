resource "github_repository" "cookbook-vmware-fusion" {
  name          = "cookbook-vmware-fusion"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "cookbook-vmware-fusion_developers" {
  repository = "${github_repository.cookbook-vmware-fusion.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "cookbook-vmware-fusion_service-accounts-read-only" {
  repository = "${github_repository.cookbook-vmware-fusion.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
