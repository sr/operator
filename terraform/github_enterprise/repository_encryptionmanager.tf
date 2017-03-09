resource "github_repository" "encryptionmanager" {
  name          = "encryptionmanager"
  description   = ""
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "encryptionmanager_developers" {
  repository = "${github_repository.encryptionmanager.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "encryptionmanager_service-accounts-read-only" {
  repository = "${github_repository.encryptionmanager.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "encryptionmanager_service-accounts-write-only" {
  repository = "${github_repository.encryptionmanager.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "encryptionmanager_service-accounts-administrators" {
  repository = "${github_repository.encryptionmanager.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
