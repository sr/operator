require "optparse"
require "pp"

require "octokit"

options = { org: "Pardot" }
OptionParser.new do |opts|
  opts.on("-o", "--org [NAME]", "") do |v|
    options[:org] = v
  end

  opts.on("-r", "--[no-]repos", "") do |v|
    options[:repos] = v
  end

  opts.on("-t", "--[no-]teams", "") do |v|
    options[:teams] = v
  end
end.parse!

Octokit.configure do |c|
  c.api_endpoint = "https://git.dev.pardot.com/api/v3"
  c.login = ENV["GITHUB_USER"]
  c.password = ENV["GITHUB_PASSWORD"]
end

if options[:repos]
  Octokit.organization_repositories(options[:org]).each do |repo|
    if repo.fork?
      fail "fork detected: #{repo.name}"
    end

    puts %Q{
resource "github_repository" "#{repo.name}" {
  name        = "#{repo.name}"
  description = "#{repo.description.gsub('"', '\"')}"
  homepage_url = "#{repo.homepage_url}"
  private = false
  has_issues = false
  has_downloads = false
  has_wiki = false
  auto_init = false
}
}
  end
end

if options[:teams]
  Octokit.organization_teams(options[:org]).each do |team|
    puts %Q{
resource "github_team" "#{team.slug}" {
  name = "#{team.name}"
  description = "#{team.description.gsub('"', '\"')}"
  privacy = "closed"
}
}
  end
end
