require "uri"

module Bamboo
  class Client
    def initialize(url: "https://bamboo.dev.pardot.com", username: ENV["BAMBOO_USERNAME"], password: ENV["BAMBOO_PASSWORD"])
      @url      = URI(url)
      @username = username
      @password = password
    end

    def create_plan_branch(project_key:, build_key:, branch:)
      safe_branch = branch.gsub(/[^A-Za-z0-9-]/, "-")

      resp = Net::HTTP.start(@url.host, @url.scheme == "https" ? 443 : 80, use_ssl: (@url.scheme == "https")) do |http|
        req = Net::HTTP::Put.new("/rest/api/latest/plan/#{project_key}-#{build_key}/branch/#{safe_branch}?vcsBranch=refs/heads/#{branch}")
        http.request(req)
      end

      if Net::HTTPSuccess === resp || /This name is already used/ =~ resp.body
        true
      else
        raise "Unable to create plan branch: #{resp.body}"
      end
    end
  end
end
