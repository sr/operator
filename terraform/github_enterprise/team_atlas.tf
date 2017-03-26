resource "github_team" "atlas" {
  name        = "Atlas"
  description = "Owners of the Salesforce-Package repository"
  privacy     = "closed"
}

resource "github_team_membership" "atlas_joe-goble" {
  team_id  = "${github_team.atlas.id}"
  username = "joe-goble"
  role     = "maintainer"
}
