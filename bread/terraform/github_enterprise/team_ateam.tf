resource "github_team" "ateam" {
  name        = "A-Team"
  description = "https://gus.lightning.force.com/one/one.app#/sObject/a00B0000005MPjtIAG/view"
  privacy     = "closed"
}

resource "github_team_membership" "ateam_william-castillo" {
  team_id  = "${github_team.ateam.id}"
  username = "william-castillo"
  role     = "maintainer"
}

resource "github_team_membership" "ateam_david-peterson" {
  team_id  = "${github_team.ateam.id}"
  username = "david-peterson"
  role     = "maintainer"
}
