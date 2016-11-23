resource "github_repository" "pardot-magento" {
  name          = "pardot-magento"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-magento_developers" {
  repository = "${github_repository.pardot-magento.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-magento_service-accounts-read-only" {
  repository = "${github_repository.pardot-magento.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
