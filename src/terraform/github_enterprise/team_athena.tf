resource "github_team" "athena" {
  name        = "Athena"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Athena"
  privacy     = "closed"
}

resource "github_team_membership" "athena_rob-righter" {
  team_id  = "${github_team.athena.id}"
  username = "rob-righter"
  role     = "maintainer"
}

resource "github_team_membership" "athena_yiping-wolgemuth" {
  team_id  = "${github_team.athena.id}"
  username = "yiping-wolgemuth"
  role     = "maintainer"
}

resource "github_team_membership" "athena_nathan-maphet" {
  team_id  = "${github_team.athena.id}"
  username = "nathan-maphet"
  role     = "maintainer"
}

resource "github_team_membership" "athena_patrick-price" {
  team_id  = "${github_team.athena.id}"
  username = "patrick-price"
  role     = "maintainer"
}

resource "github_team_membership" "athena_gauri-mawalankar" {
  team_id  = "${github_team.athena.id}"
  username = "gauri-mawalankar"
  role     = "maintainer"
}
