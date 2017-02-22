resource "github_team" "apollo-13" {
  name        = "Apollo 13"
  description = "https://confluence.dev.pardot.com/display/PE/Apollo+13"
  privacy     = "closed"
}

resource "github_team_membership" "apollo-13_nikita-makeyev" {
  team_id  = "${github_team.apollo-13.id}"
  username = "nikita-makeyev"
  role     = "maintainer"
}

resource "github_team_membership" "apollo-13_amy-kasing" {
  team_id  = "${github_team.apollo-13.id}"
  username = "amy-kasing"
  role     = "maintainer"
}