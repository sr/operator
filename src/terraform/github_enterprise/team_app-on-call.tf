resource "github_team" "app-on-call" {
  name        = "App On-Call"
  description = "http://sfdc.co/pre-rotation"
  privacy     = "closed"
}

resource "github_team_membership" "app-on-call" {
  team_id  = "${github_team.app-on-call.id}"
  username = "nathan-maphet"
  role     = "maintainer"
}
