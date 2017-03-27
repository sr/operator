resource "github_repository" "redis-roaring" {
  name          = "redis-roaring"
  description   = "Roaring bitmaps as a Redis Module"
  homepage_url  = ""
  private       = false
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_branch_protection" "redis-roaring_master" {
  repository = "${github_repository.redis-roaring.name}"
  branch     = "master"

  required_status_checks {
    include_admins = false
    strict         = false
    contexts       = ["compliance"]
  }
}

resource "github_team_repository" "redis-roaring_developers" {
  repository = "${github_repository.redis-roaring.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "redis-roaring_service-accounts-administrators" {
  repository = "${github_repository.redis-roaring.name}"
  team_id    = "${github_team.service-accounts-administrators.id}"
  permission = "admin"
}

resource "github_team_repository" "redis-roaring_service-accounts-write-only" {
  repository = "${github_repository.redis-roaring.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "redis-roaring_service-accounts-read-only" {
  repository = "${github_repository.redis-roaring.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
