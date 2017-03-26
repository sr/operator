resource "github_team" "hades" {
  name        = "Hades"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Hades"
  privacy     = "closed"
}

resource "github_team_membership" "hades_rob-righter" {
  team_id  = "${github_team.hades.id}"
  username = "rob-righter"
  role     = "maintainer"
}

resource "github_team_membership" "hades_yiping-wolgemuth" {
  team_id  = "${github_team.hades.id}"
  username = "yiping-wolgemuth"
  role     = "maintainer"
}

resource "github_team_membership" "hades_nathan-maphet" {
  team_id  = "${github_team.hades.id}"
  username = "nathan-maphet"
  role     = "maintainer"
}

resource "github_team_membership" "hades_patrick-price" {
  team_id  = "${github_team.hades.id}"
  username = "patrick-price"
  role     = "maintainer"
}

resource "github_team_membership" "hades_gauri-mawalankar" {
  team_id  = "${github_team.hades.id}"
  username = "gauri-mawalankar"
  role     = "maintainer"
}
