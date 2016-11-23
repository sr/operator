resource "github_repository" "MySQL_Benchmark" {
  name          = "MySQL_Benchmark"
  description   = "MySQL Benchmark - FedEX"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "MySQL_Benchmark_developers" {
  repository = "${github_repository.MySQL_Benchmark.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "MySQL_Benchmark_ops" {
  repository = "${github_repository.MySQL_Benchmark.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "MySQL_Benchmark_service-accounts-read-only" {
  repository = "${github_repository.MySQL_Benchmark.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
