terraform {
  backend "artifactory" {
    url     = "https://artifactory.dev.pardot.com/artifactory"
    repo    = "pd-terraform"
    subpath = "aws/pardotpublic"
  }
}
