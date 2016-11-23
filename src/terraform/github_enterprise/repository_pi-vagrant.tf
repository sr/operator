resource "github_repository" "pi-vagrant" {
  name          = "pi-vagrant"
  description   = "DEPRECATED: pi-vagrant is a lightweight way to get going with pardot development on a vagrant-managed virtual machine"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pi-vagrant_developers" {
  repository = "${github_repository.pi-vagrant.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pi-vagrant_ops" {
  repository = "${github_repository.pi-vagrant.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}
