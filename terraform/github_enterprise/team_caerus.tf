resource "github_team" "caerus" {
  name        = "Caerus"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Caerus"
  privacy     = "closed"
}

resource "github_team_membership" "caerus_nathan-maphet" {
  team_id  = "${github_team.caerus.id}"
  username = "nathan-maphet"
  role     = "maintainer"
}
