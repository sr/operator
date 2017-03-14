
resource "github_team" "q3" {
  name        = "Q3"
  description = "https://gus.lightning.force.com/one/one.app#/sObject/a00B0000005MSsZIAW/view"
  privacy     = "closed"
}

resource "github_team_membership" "q3_troy-hill" {
  team_id  = "${github_team.daleks.id}"
  username = "troy-hill"
  role     = "maintainer"
}

resource "github_team_membership" "q3_heather-dartz" {
  team_id  = "${github_team.daleks.id}"
  username = "heather-dartz"
  role     = "maintainer"
}

resource "github_team_membership" "q3_tinny-washington" {
  team_id  = "${github_team.daleks.id}"
  username = "tinny-washington"
  role     = "maintainer"
}

resource "github_team_membership" "q3_bernalpatrick" {
  team_id  = "${github_team.daleks.id}"
  username = "bernalpatrick"
  role     = "maintainer"
}

resource "github_team_membership" "q3_jeff-elrod" {
  team_id  = "${github_team.daleks.id}"
  username = "jeff-elrod"
  role     = "maintainer"
}

