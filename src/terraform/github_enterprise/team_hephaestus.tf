resource "github_team" "hephaestus" {
  name        = "Hephaestus"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Hephaestus"
  privacy     = "closed"
}

resource "github_team_membership" "hephaestus_nathan-maphet" {
  team_id  = "${github_team.hephaestus.id}"
  username = "nathan-maphet"
  role     = "maintainer"
}

resource "github_team_membership" "hephaestus_oliver-albrecht" {
  team_id  = "${github_team.hephaestus.id}"
  username = "oliver-albrecht"
  role     = "maintainer"
}