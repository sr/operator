resource "github_team" "apollo" {
  name        = "apollo"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Apollo"
  privacy     = "closed"
}

resource "github_team_membership" "apollo_rob-righter" {
  team_id  = "${github_team.apollo.id}"
  username = "rob-righter"
  role     = "maintainer"
}

resource "github_team_membership" "apollo_yiping-wolgemuth" {
  team_id  = "${github_team.apollo.id}"
  username = "yiping-wolgemuth"
  role     = "maintainer"
}

resource "github_team_membership" "apollo_nathan-maphet" {
  team_id  = "${github_team.apollo.id}"
  username = "nathan-maphet"
  role     = "maintainer"
}

resource "github_team_membership" "apollo_patrick-price" {
  team_id  = "${github_team.apollo.id}"
  username = "patrick-price"
  role     = "maintainer"
}

resource "github_team_membership" "apollo_gauri-mawalankar" {
  team_id  = "${github_team.apollo.id}"
  username = "gauri-mawalankar"
  role     = "maintainer"
}
