resource "github_repository" "SalesReachLicenseProvisioning" {
  name          = "SalesReachLicenseProvisioning"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "SalesReachLicenseProvisioning_developers" {
  repository = "${github_repository.SalesReachLicenseProvisioning.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "SalesReachLicenseProvisioning_service-accounts-read-only" {
  repository = "${github_repository.SalesReachLicenseProvisioning.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}