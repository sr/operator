resource "github_repository" "protobuf-schemas" {
  name          = "protobuf-schemas"
  description   = "One stop shop for Protocol Buffer Schema Definitions "
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "protobuf-schemas_master" {
  repository = "${github_repository.protobuf-schemas.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "protobuf-schemas_developers" {
  repository = "${github_repository.protobuf-schemas.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "protobuf-schemas_service-accounts-write-only" {
  repository = "${github_repository.protobuf-schemas.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "protobuf-schemas_service-accounts-read-only" {
  repository = "${github_repository.protobuf-schemas.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "protobuf-schemas_read-only-users" {
  repository = "${github_repository.protobuf-schemas.name}"
  team_id    = "${github_team.read-only-users.id}"
  permission = "pull"
}

resource "github_team_repository" "protobuf-schemas_service-accounts-administrators" {
  repository = "${github_repository.protobuf-schemas.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
