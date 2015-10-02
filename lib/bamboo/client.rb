require "uri"
require "nokogiri"

module Bamboo
  class Client
    Error = Class.new(StandardError)

    def initialize(url: "https://bamboo.dev.pardot.com", username: ENV["BAMBOO_USERNAME"], password: ENV["BAMBOO_PASSWORD"])
      raise ArgumentError, "Bamboo username is required" unless username.present?
      raise ArgumentError, "Bamboo password is required" unless password.present?

      @url      = URI(url)
      @username = username
      @password = password
    end

    def plan_branch(project_key:, build_key:, branch:)
      resp = with_client do |http|
        req = Net::HTTP::Get.new("/rest/api/latest/plan/#{project_key}-#{build_key}/branch/#{branch_name_key(branch)}")
        req.basic_auth(@username, @password)
        http.request(req)
      end

      if Net::HTTPNoContent === resp || Net::HTTPNotFound === resp
        # Bamboo returns a 204 if the branch isn't found (wat)
        nil
      elsif Net::HTTPSuccess === resp
        doc = Nokogiri::XML(resp.body)
        if branch = doc.at_xpath("/branch")
          {
            plan_key: branch["key"],
          }
        else
          raise Error, "Unable to extract plan key: #{resp.body}"
        end
      else
        raise Error, "Unable to find plan branch: #{resp.body}"
      end
    end

    def create_plan_branch(project_key:, build_key:, branch:)
      resp = with_client do |http|
        req = Net::HTTP::Put.new("/rest/api/latest/plan/#{project_key}-#{build_key}/branch/#{branch_name_key(branch)}?vcsBranch=#{CGI.escape(branch)}")
        req["content-type"] = "application/xml"
        req.basic_auth(@username, @password)
        http.request(req)
      end

      if Net::HTTPSuccess === resp
        doc = Nokogiri::XML(resp.body)
        if result = doc.at_xpath("/branch")
          {
            plan_key: result["key"],
          }
        else
          raise Error, "Unable to extract plan information: #{resp.body}"
        end
      else
        raise Error, "Unable to create plan branch: #{resp.body}"
      end
    end

    def update_plan_branch(plan_key:, branch:, enabled: true, clean_up_plan_automatically: true)
      resp = with_client do |http|
        req = Net::HTTP::Post.new("/branch/admin/config/saveChainBranchDetails.action")
        req["x-atlassian-token"] = "no-check"
        req.form_data = {
          buildKey: plan_key,
          planKey: plan_key,
          branchName: branch_name_key(branch),
          enabled: enabled.to_s,
          planBranchCleanUpEnabled: clean_up_plan_automatically.to_s,
        }
        req.basic_auth(@username, @password)
        http.request(req)
      end

      if Net::HTTPSuccess === resp || Net::HTTPRedirection === resp
        true
      else
        raise Error, "Unable to update plan branch: #{resp.body}"
      end
    end

    def latest_result(plan_key:, include_all_states: true)
      resp = with_client do |http|
        req = Net::HTTP::Get.new("/rest/api/latest/result/#{plan_key}/latest?includeAllStates=#{include_all_states}")
        req.basic_auth(@username, @password)
        http.request(req)
      end

      if Net::HTTPSuccess === resp
        doc = Nokogiri::XML(resp.body)
        if result = doc.at_xpath("/result")
          {
            build_result_key: result["key"],
            state: result["state"].downcase,
            life_cycle_state: result["lifeCycleState"].downcase,
          }
        end
      elsif Net::HTTPNotFound === resp
        nil
      else
        raise Error, "Unable to find latest build result: #{resp.body}"
      end
    end

    def queue_build(plan_key:)
      resp = with_client do |http|
        req = Net::HTTP::Post.new("/rest/api/latest/queue/#{plan_key}?executeAllStages=true")
        req["content-type"] = "application/xml"
        req.basic_auth(@username, @password)
        http.request(req)
      end

      if Net::HTTPSuccess === resp
        doc = Nokogiri::XML(resp.body)
        if result = doc.at_xpath("/restQueuedBuild")
          {
            build_result_key: result["buildResultKey"],
          }
        else
          raise Error, "Unable to extract build result key: #{resp.body}"
        end
      else
        raise Error, "Unable to queue build: #{resp.body}"
      end
    end

    private
    def with_client(ssl = true, &blk)
      if ssl
        Net::HTTP.start(@url.host, @url.scheme == "https" ? 443 : 80, use_ssl: (@url.scheme == "https"), &blk)
      else
        Net::HTTP.start(@url.host, 80, use_ssl: false, &blk)
      end
    end

    def branch_name_key(branch)
      branch.gsub(/[^A-Za-z0-9-]/, "-")
    end
  end
end
