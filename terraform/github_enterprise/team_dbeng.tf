resource "github_team" "dbeng" {
  name        = "DBEng"
  description = "https://gus.lightning.force.com/one/one.app#/sObject/a00B0000005MPjyIAG/view"
  privacy     = "closed"
}

resource "github_team_membership" "dbeng_william-castillo" {
  team_id  = "${github_team.dbeng.id}"
  username = "william-castillo"
  role     = "maintainer"
}

resource "github_team_membership" "dbeng_david-peterson" {
  team_id  = "${github_team.dbeng.id}"
  username = "david-peterson"
  role     = "maintainer"
}

resource "github_team_membership" "dbeng_glenn-nadeau" {
  team_id  = "${github_team.dbeng.id}"
  username = "glenn-nadeau"
  role     = "maintainer"
}

