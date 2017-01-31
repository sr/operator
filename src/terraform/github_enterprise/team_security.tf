resource "github_team" "security" {
  name        = "Security"
  description = "https://confluence.dev.pardot.com/display/SECURITY"
  privacy     = "closed"
}

resource "github_team_membership" "security_mike-lockhart" {
  team_id  = "${github_team.security.id}"
  username = "mike-lockhart"
  role     = "maintainer"
}
