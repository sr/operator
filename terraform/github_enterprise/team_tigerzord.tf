resource "github_team" "tigerzord" {
  name        = "Tigerzord"
  description = "https://confluence.dev.pardot.com/display/PE/Marketing+Insights+Program"
  privacy     = "closed"
}

resource "github_team_membership" "tigerzord_joey-rivera" {
  team_id  = "${github_team.tigerzord.id}"
  username = "joey-rivera"
  role     = "maintainer"
}

resource "github_team_membership" "tigerzord_danny-knapp" {
  team_id  = "${github_team.tigerzord.id}"
  username = "danny-knapp"
  role     = "maintainer"
}

resource "github_team_membership" "tigerzord_elliott-asher" {
  team_id  = "${github_team.tigerzord.id}"
  username = "elliott-asher"
  role     = "maintainer"
}

resource "github_team_membership" "tigerzord_juan-nunez" {
  team_id  = "${github_team.tigerzord.id}"
  username = "juan-nunez"
  role     = "maintainer"
}

resource "github_team_membership" "tigerzord_bryan-oleary" {
  team_id  = "${github_team.tigerzord.id}"
  username = "bryan-oleary"
  role     = "maintainer"
}
