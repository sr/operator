resource "github_repository" "pardot-java-models" {
  name          = "pardot-java-models"
  description   = "Java Models for Pardot"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_branch_protection" "pardot-java-models_master" {
  repository = "${github_repository.pardot-java-models.name}"
  branch     = "master"

  include_admins = false
  strict         = false
  contexts       = ["compliance"]
}

resource "github_team_repository" "pardot-java-models_developers" {
  repository = "${github_repository.pardot-java-models.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-java-models_service-accounts-read-only" {
  repository = "${github_repository.pardot-java-models.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "pardot-java-models_service-accounts-write-only" {
  repository = "${github_repository.pardot-java-models.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-java-models_service-accounts-administrators" {
  repository = "${github_repository.pardot-java-models.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}
