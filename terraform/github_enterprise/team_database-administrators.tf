resource "github_team" "database-administrators" {
  name        = "Database Administrators"
  description = "https://gus.lightning.force.com/one/one.app#/sObject/a00B0000005MPjyIAG/view"
  privacy     = "closed"
}

resource "github_team_membership" "database-administrators_william-castillo" {
  team_id  = "${github_team.database-administrators.id}"
  username = "william-castillo"
  role     = "maintainer"
}

resource "github_team_membership" "database-administrators_david-peterson" {
  team_id  = "${github_team.database-administrators.id}"
  username = "david-peterson"
  role     = "maintainer"
}

resource "github_team_membership" "database-administrators_glenn-nadeau" {
  team_id  = "${github_team.database-administrators.id}"
  username = "glenn-nadeau"
  role     = "maintainer"
}

