resource "github_team" "q3" {
  name        = "q3"
  description = "https://gus.lightning.force.com/one/one.app#/sObject/a00B0000005MSsZIAW/view"
  privacy     = "closed"
}

resource "github_team_membership" "q3_troy-hill" {
  team_id  = "${github_team.q3.id}"
  username = "troy-hill"
  role     = "maintainer"
}

resource "github_team_membership" "q3_heather-dartz" {
  team_id  = "${github_team.q3.id}"
  username = "heather-dartz"
  role     = "maintainer"
}
