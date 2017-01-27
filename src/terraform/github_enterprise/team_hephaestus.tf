resource "github_team" "hephaestus" {
  name        = "hephaestus"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Hephaestus"
  privacy     = "closed"
}

resource "github_team_membership" "hephaestus_oliver-albrecht" {
  team_id  = "${github_team.hephaestus.id}"
  username = "oliver-albrecht"
  role     = "maintainer"
}
