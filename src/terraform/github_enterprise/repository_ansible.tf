resource "github_repository" "ansible" {
  name          = "ansible"
  description   = "Basic Ansible Plays to complement other Ops tools."
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "ansible_ops" {
  repository = "${github_repository.ansible.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "ansible_service-accounts-read-only" {
  repository = "${github_repository.ansible.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "ansible_service-accounts-write-only" {
  repository = "${github_repository.ansible.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "ansible_developers" {
  repository = "${github_repository.ansible.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_branch_protection" "ansible_master" {
  repository = "${github_repository.ansible.name}"
  branch     = "master"

  include_admins = true
  strict         = false
  contexts       = ["Test Jobs"]
}
