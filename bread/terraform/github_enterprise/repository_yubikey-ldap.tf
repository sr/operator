resource "github_repository" "yubikey-ldap" {
  name          = "yubikey-ldap"
  description   = "Fork of the original yubikey-ldap project"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "yubikey-ldap_master" {
  repository = "${github_repository.yubikey-ldap.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "yubikey-ldap_service-accounts-read-only" {
  repository = "${github_repository.yubikey-ldap.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "yubikey-ldap_service-accounts-write-only" {
  repository = "${github_repository.yubikey-ldap.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "yubikey-ldap_service-accounts-administrators" {
  repository = "${github_repository.yubikey-ldap.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
