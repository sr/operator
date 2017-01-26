resource "github_team" "triton" {
  name        = "Triton"
  description = "https://confluence.dev.pardot.com/display/PE/Team+Triton"
  privacy     = "closed"
}

resource "github_team_membership" "triton_stan-lemon" {
  team_id  = "${github_team.triton.id}"
  username = "stan-lemon"
  role     = "maintainer"
}
