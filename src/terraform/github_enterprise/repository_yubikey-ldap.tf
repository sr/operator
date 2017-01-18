resource "github_repository" "yubikey-ldap" {
  name          = "yubikey-ldap"
  description   = "Fork of the original yubikey-ldap project"
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
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
