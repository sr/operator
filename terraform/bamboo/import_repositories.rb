require "optparse"
require "pp"

require "octokit"

Dir.chdir(File.dirname(__FILE__))

options = { org: "Pardot" }
OptionParser.new do |opts|
  opts.on("-o", "--org [NAME]", "") do |v|
    options[:org] = v
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

File.open("repositories.tf", "a") do |fp|
  Octokit.organization_repositories(options[:org]).each do |repo|
    safe_name = repo.name.gsub(".", "-")
    if %x(terraform state show bamboo_repository.#{safe_name}).strip.empty?
      puts "Adding bamboo_repository.#{safe_name} ..."

      fp.puts <<-EOS
resource "bamboo_repository" "#{safe_name}" {
  name           = "#{safe_name}"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "#{options[:org]}/#{repo.name}"
  shallow_clones = true
}
EOS
      if options[:import]
        system("terraform", "import", "-var-file=../terraform.tfvars", "bamboo_repository.#{safe_name}", "#{repo.name}", out: :err)
      end
    end
  end
end
