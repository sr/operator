resource "github_team" "bread" {
  name        = "BREAD"
  description = ""
  privacy     = "closed"
}

resource "github_team" "core-production-security" {
  name        = "Core Production Security"
  description = ""
  privacy     = "closed"
}

resource "github_team" "database-administrators" {
  name        = "Database Administrators"
  description = ""
  privacy     = "closed"
}

resource "github_team" "developers" {
  name        = "Developers"
  description = "DEVLEOPERZ DEVOLEPRZ JACKALOPES"
  privacy     = "closed"
}

resource "github_team" "documentation-editors" {
  name        = "Documentation Editors"
  description = ""
  privacy     = "closed"
}

resource "github_team" "ops" {
  name        = "Ops"
  description = "The Dark Side"
  privacy     = "closed"
}

resource "github_team" "service-accounts-read-only" {
  name        = "Service Accounts read-only"
  description = ""
  privacy     = "secret"
}

resource "github_team" "service-accounts-write-only" {
  name        = "Service Accounts write-only"
  description = ""
  privacy     = "secret"
}

resource "github_team" "tier-2-support" {
  name        = "Tier 2 Support"
  description = "Tier 2 Support"
  privacy     = "closed"
}

resource "github_team" "triton" {
  name        = "Triton"
  description = "We manage engagement history, which syncs activities and campaigns to Salesforce"
  privacy     = "closed"
}

resource "github_team" "read-only-users" {
  name        = "Read-Only Users"
  description = "Read-Only Access for CORE CCE to setup dev env locally and test"
  privacy     = "secret"
}

resource "github_team" "site-reliability-engineers" {
  name        = "Site Reliability Engineers"
  description = "Site Reliability Engineering Team"
  privacy     = "closed"
}

resource "github_team" "engineering-managers" {
  name        = "Engineering Managers"
  description = "Engineering Managers under Zach Bailey"
  privacy     = "closed"
}
