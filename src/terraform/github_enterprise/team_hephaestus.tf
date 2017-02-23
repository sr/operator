resource "github_team" "hephaestus" {
  name        = "Hephaestus"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Hephaestus"
  privacy     = "closed"
}

resource "github_team_membership" "hephaestus_dave-leach" {
  team_id  = "${github_team.hephaestus.id}"
  username = "dave-leach"
  role     = "maintainer"
}

resource "github_team_membership" "hephaestus_john-ulman" {
  team_id  = "${github_team.hephaestus.id}"
  username = "john-ulman"
  role     = "maintainer"
}

resource "github_team_membership" "hephaestus_oliver-albrecht" {
  team_id  = "${github_team.hephaestus.id}"
  username = "oliver-albrecht"
  role     = "maintainer"
}

resource "github_team_membership" "hephaestus_samuel-kim" {
  team_id  = "${github_team.hephaestus.id}"
  username = "samuel-kim"
  role     = "maintainer"
}

resource "github_team_membership" "hephaestus_steve-schraudner" {
  team_id  = "${github_team.hephaestus.id}"
  username = "steve-schraudner"
  role     = "maintainer"
}