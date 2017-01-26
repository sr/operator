resource "github_team" "triton" {
  name        = "Caerus"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Triton"
  privacy     = "closed"
}

resource "github_team_membership" "triton_stan-lemon" {
  team_id  = "${github_team.caerus.id}"
  username = "stan-lemon"
  role     = "maintainer"
}
