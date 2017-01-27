resource "github_repository" "provisioning-service" {
  name          = "provisioning-service"
  description   = "Account Provisioning Magic"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "provisioning-service_developers" {
  repository = "${github_repository.provisioning-service.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "provisioning-service_service-accounts-read-only" {
  repository = "${github_repository.provisioning-service.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "provisioning-service_site-reliability-engineers" {
  repository = "${github_repository.provisioning-service.name}"
  team_id    = "${github_team.site-reliability-engineers.id}"
  permission = "admin"
}

resource "github_team_repository" "provisioning-service_engineering-managers" {
  repository = "${github_repository.provisioning-service.name}"
  team_id    = "${github_team.engineering-managers.id}"
  permission = "admin"
}

resource "github_team_repository" "provisioning-service_service-accounts-write-only" {
  repository = "${github_repository.provisioning-service.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}