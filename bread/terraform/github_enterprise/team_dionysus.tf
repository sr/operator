resource "github_team" "dionysus" {
  name        = "Dionysus"
  description = "https://confluence.dev.pardot.com/display/PE/Integration+Program"
  privacy     = "closed"
}

resource "github_team_membership" "dionysus_rob-righter" {
  team_id  = "${github_team.dionysus.id}"
  username = "rob-righter"
  role     = "maintainer"
}

resource "github_team_membership" "dionysus_yiping-wolgemuth" {
  team_id  = "${github_team.dionysus.id}"
  username = "yiping-wolgemuth"
  role     = "maintainer"
}

resource "github_team_membership" "dionysus_nathan-maphet" {
  team_id  = "${github_team.dionysus.id}"
  username = "nathan-maphet"
  role     = "maintainer"
}

resource "github_team_membership" "dionysus_patrick-price" {
  team_id  = "${github_team.dionysus.id}"
  username = "patrick-price"
  role     = "maintainer"
}

resource "github_team_membership" "dionysus_gauri-mawalankar" {
  team_id  = "${github_team.dionysus.id}"
  username = "gauri-mawalankar"
  role     = "maintainer"
}
