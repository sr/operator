resource "github_team" "derweze" {
  name        = "Derweze"
  description = "https://confluence.dev.pardot.com/pages/viewpage.action?pageId=15991897"
  privacy     = "closed"
}

resource "github_team_membership" "derweze_michael-frank" {
  team_id  = "${github_team.derweze.id}"
  username = "michael-frank"
  role     = "maintainer"
}

resource "github_team_membership" "derweze_keith-smiley" {
  team_id  = "${github_team.derweze.id}"
  username = "keith-smiley"
  role     = "maintainer"
}

resource "github_team_membership" "derweze_natalie-marion" {
  team_id  = "${github_team.derweze.id}"
  username = "natalie-marion"
  role     = "maintainer"
}

resource "github_team_membership" "derweze_arris-ray" {
  team_id  = "${github_team.derweze.id}"
  username = "arris-ray"
  role     = "maintainer"
}

resource "github_team_membership" "derweze_matt-kiely" {
  team_id  = "${github_team.derweze.id}"
  username = "matt-kiely"
  role     = "maintainer"
}
