require "optparse"
require "pp"

require "octokit"

Dir.chdir(File.dirname(__FILE__))

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

  opts.on("-i", "--[no-]import", "") do |i|
    options[:import] = i
  end
end.parse!

Octokit.configure do |c|
  c.api_endpoint = "https://git.dev.pardot.com/api/v3"
  c.access_token = ENV.fetch("GITHUB_ACCESS_TOKEN")
end

if options[:repos]
  Octokit.organization_repositories(options[:org]).each do |repo|
    if repo.fork?
      fail "fork detected: #{repo.name}"
    end

    puts <<-EOS
resource "github_repository" "#{repo.name}" {
  name        = "#{repo.name}"
  description = "#{repo.description.gsub('"', '\"')}"
  homepage_url = "#{repo.homepage_url}"
  private = #{repo.private}
  has_issues = #{repo.has_issues}
  has_downloads = #{repo.has_downloads}
  has_wiki = #{repo.has_wiki}
}
EOS
    Octokit.repository_teams(repo.id).each do |team|
      puts <<-EOS
resource "github_team_repository" "#{repo.name}_#{team.slug}" {
  repository = "\${github_repository.#{repo.name}.name}"
  team_id = "\${github_team.#{team.slug}.id}"
  permission = "#{team.permission}"
}
EOS

      if options[:import]
        system("terraform", "import", "-var-file=../terraform.tfvars", "github_team_repository.#{repo.name}_#{team.slug}", "#{team.id}:#{repo.name}", out: :err)
      end
    end

    if options[:import]
      system("terraform", "import", "-var-file=../terraform.tfvars", "github_repository.#{repo.name}", repo.name, out: :err)
    end
  end
end

if options[:teams]
  Octokit.organization_teams(options[:org]).each do |team|
    puts <<-EOS
resource "github_team" "#{team.slug}" {
  name = "#{team.name}"
  description = "#{team.description.gsub('"', '\"')}"
  privacy = "closed"
}
EOS

    if options[:import]
      system("terraform", "import", "-var-file=../terraform.tfvars", "github_team.#{team.slug}", team.id.to_s, out: :err)
    end
  end
end
