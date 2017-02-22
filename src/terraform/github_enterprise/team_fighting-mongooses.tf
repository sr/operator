resource "github_team" "fighting-mongooses" {
  name        = "The Fighting Mongooses"
  description = "https://gus.lightning.force.com/one/one.app#/sObject/0F9B00000003XyeKAE/view"
  privacy     = "closed"
}

resource "github_team_membership" "fighting-mongooses_lipi-agarwal" {
  team_id  = "${github_team.fighting-mongooses.id}"
  username = "lipi-agarwal"
  role     = "maintainer"
}

resource "github_team_membership" "fighting-mongooses_melody-bonnette" {
  team_id  = "${github_team.fighting-mongooses.id}"
  username = "melody-bonnette"
  role     = "maintainer"
}

resource "github_team_membership" "fighting-mongooses_donald-gowens" {
  team_id  = "${github_team.fighting-mongooses.id}"
  username = "donald-gowens"
  role     = "maintainer"
}

resource "github_team_membership" "fighting-mongooses_chris-kelly" {
  team_id  = "${github_team.fighting-mongooses.id}"
  username = "chris-kelly"
  role     = "maintainer"
}

resource "github_team_membership" "fighting-mongooses_chris-little" {
  team_id  = "${github_team.fighting-mongooses.id}"
  username = "chris-little"
  role     = "maintainer"
}

resource "github_team_membership" "fighting-mongooses_russell-rollins" {
  team_id  = "${github_team.fighting-mongooses.id}"
  username = "russell-rollins"
  role     = "maintainer"
}
