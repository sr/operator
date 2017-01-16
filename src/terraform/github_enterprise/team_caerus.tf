resource "github_team" "caerus" {
  name        = "Caerus"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Caerus"
  privacy     = "closed"
}

resource "github_team_membership" "caerus_nathan-maphet" {
  team_id  = "${github_team.caerus.id}"
  username = "nathan-maphet"
  role     = "maintainer"
}

resource "github_team_membership" "caerus_andy-fischoff" {
  team_id  = "${github_team.caerus.id}"
  username = "andy-fischoff"
  role     = "maintainer"
}

resource "github_team_membership" "caerus_michael-noga" {
  team_id  = "${github_team.caerus.id}"
  username = "michael-noga"
  role     = "maintainer"
}

resource "github_team_membership" "caerus_mei-mccullar" {
  team_id  = "${github_team.caerus.id}"
  username = "mei-mccullar"
  role     = "maintainer"
}

resource "github_team_membership" "caerus_arnaud-thabot" {
  team_id  = "${github_team.caerus.id}"
  username = "arnaud-thabot"
  role     = "maintainer"
}
