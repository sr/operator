resource "github_team" "engagement-studio" {
  name        = "engagement-studio"
  description = "We increase customer success and satisfaction by enhancing our existing suite of tools that encompass our marketing execution engine. (Multi-Project)"
  privacy     = "closed"
}

resource "github_team_membership" "engagement-studio_satya-bhan" {
  team_id  = "${github_team.engagement-studio.id}"
  username = "satya-bhan"
  role     = "maintainer"
}

resource "github_team_membership" "engagement-studio_eric-berg" {
  team_id  = "${github_team.engagement-studio.id}"
  username = "eric-berg"
  role     = "maintainer"
}

resource "github_team_membership" "engagement-studio_chris-brown" {
  team_id  = "${github_team.engagement-studio.id}"
  username = "chris-brown"
  role     = "maintainer"
}

resource "github_team_membership" "engagement-studio_stephen-powis" {
  team_id  = "${github_team.engagement-studio.id}"
  username = "stephen-powis"
  role     = "maintainer"
}

