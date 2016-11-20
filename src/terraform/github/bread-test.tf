variable "github_token" {}

# Configure the GitHub Provider
provider "github" {
  token        = "${var.github_token}"
  organization = "bread-test"
  base_url     = "https://git.dev.pardot.com/api/v3/"
}

resource "github_repository" "example" {
  name        = "example"
  description = "My awesome codebase"
  private     = true
}
