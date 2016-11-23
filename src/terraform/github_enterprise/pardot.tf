variable "github_enterprise_token" {}

provider "github" {
  token        = "${var.github_enterprise_token}"
  organization = "pardot"
  base_url     = "https://git.dev.pardot.com/api/v3/"
}
