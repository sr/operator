resource "github_repository" "DF15demoapp" {
  name          = "DF15demoapp"
  description   = "The small photo app used to trigger an \"alert\" for the DF15 super session demo."
  homepage_url  = ""
  private       = false
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}
