resource "github_team" "kyber" {
  name        = "Kyber"
  description = "https://gus.my.salesforce.com/apex/adm_scrumteamdetail?id=a00B0000000yLy0IAE"
  privacy     = "closed"
}

resource "github_team_membership" "kyber_stephen-powis" {
  team_id  = "${github_team.kyber.id}"
  username = "stephen-powis"
  role     = "maintainer"
}

resource "github_team_membership" "kyber_stan-lemon" {
  team_id  = "${github_team.kyber.id}"
  username = "stan-lemon"
  role     = "maintainer"
}
