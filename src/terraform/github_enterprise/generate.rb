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
Octokit.auto_paginate = true

if options[:repos]
  Octokit.organization_repositories(options[:org]).each do |repo|
    safe_name = repo.name.gsub(".", "-")
    puts "Writing repository_#{safe_name}.tf ..."
    File.open("repository_#{safe_name}.tf", "w") do |fp|
      if repo.fork?
        fail "fork detected: #{repo.name}"
      end

      fp.puts <<-EOS
resource "github_repository" "#{safe_name}" {
  name          = "#{repo.name}"
  description   = "#{repo.description.to_s.gsub('"', '\"')}"
  homepage_url  = "#{repo.homepage}"
  private       = #{repo.private}
  has_issues    = #{repo.has_issues}
  has_downloads = #{repo.has_downloads}
  has_wiki      = #{repo.has_wiki}
}

EOS

      teams = Octokit.repository_teams(repo.id)

      if !teams.detect { |t| t.slug == "service-accounts-write-only" }
        teams << Struct.new(:slug, :permission).new("service-accounts-write-only", "push")
      end

      teams.each do |team|
        fp.puts <<-EOS
resource "github_team_repository" "#{safe_name}_#{team.slug}" {
  repository = "\${github_repository.#{safe_name}.name}"
  team_id    = "\${github_team.#{team.slug}.id}"
  permission = "#{team.permission}"
}

EOS
        if options[:import]
          system("terraform", "import", "-var-file=../terraform.tfvars", "github_team_repository.#{safe_name}_#{team.slug}", "#{team.id}:#{repo.name}", out: :err)
        end
      end

      Octokit.branches(repo.full_name, protected: true, accept: "application/vnd.github.loki-preview+json").each do |branch|
        protection = Octokit.branch_protection(repo.full_name, branch.name, accept: "application/vnd.github.loki-preview+json")
        fp.puts <<-EOS
resource "github_branch_protection" "#{safe_name}_#{branch.name}" {
  repository = "\${github_repository.#{safe_name}.name}"
  branch     = "#{branch.name}"
EOS

        if protection.required_status_checks
          fp.puts <<-EOS

  include_admins = #{protection.required_status_checks.include_admins}
  strict         = #{protection.required_status_checks.strict}
  contexts       = #{JSON.dump(protection.required_status_checks.contexts || [])}
EOS
        end

        if protection.restrictions
          fp.puts <<-EOS

  users_restriction = #{JSON.dump(protection.restrictions.users.map(&:login))}
  teams_restriction = #{JSON.dump(protection.restrictions.teams.map(&:slug))}
EOS
        end

        fp.puts <<-EOS
}

EOS
        if options[:import]
          system("terraform", "import", "-var-file=../terraform.tfvars", "github_branch_protection.#{safe_name}_#{branch.name}", "#{repo.name}:#{branch.name}", out: :err)
        end
      end

      if options[:import]
        system("terraform", "import", "-var-file=../terraform.tfvars", "github_repository.#{safe_name}", repo.name, out: :err)
      end
    end
  end
end

if options[:teams]
  Octokit.organization_teams(options[:org]).each do |team|
    puts "Writing teams.tf ..."
    File.open("teams.tf", "w") do |fp|
      fp.puts <<-EOS
resource "github_team" "#{team.slug}" {
  name        = "#{team.name}"
  description = "#{team.description.to_s.gsub('"', '\"')}"
  privacy     = "#{team.privacy}"
}

EOS

      if options[:import]
        system("terraform", "import", "-var-file=../terraform.tfvars", "github_team.#{team.slug}", team.id.to_s, out: :err)
      end
    end
  end
end
