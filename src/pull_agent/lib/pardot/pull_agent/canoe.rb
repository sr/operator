module Pardot
  module PullAgent
    class Canoe
      def self.notify_server(environment, deploy)
        call_api("PUT", "/api/targets/#{environment}/deploys/#{deploy.id}/results/#{ShellHelper.hostname}", action: deploy.action, success: true)
      end

      def self.latest_deploy(environment, project)
        result = call_api("GET", "/api/targets/#{environment}/deploys/latest", repo_name: project, server: ShellHelper.hostname)

        json = JSON.parse(result.body)
        Logger.log(:warn, json) unless json["id"]
        Deploy.from_hash(json)
      end

      def self.chef_checkin(request)
        call_api(
          "POST",
          "/api/chef/checkin",
          request
        )
      end

      def self.complete_chef_deploy(request)
        call_api(
          "POST",
          "/api/chef/complete_deploy",
          request
        )
      end

      def self.knife(request)
        call_api(
          "POST",
          "/api/chef/knife",
          request
        )
      end

      def self.call_api(method, path, params = {})
        Net::HTTP.start(canoe_url.host, canoe_url.port, :ENV, use_ssl: (canoe_url.scheme == "https")) do |http|
          if method == "GET"
            path += "?" + URI.encode_www_form(params)
          end
          req = case method
                when "POST" then Net::HTTP::Post.new(path)
                when "GET" then Net::HTTP::Get.new(path)
                when "PUT" then Net::HTTP::Put.new(path)
                end
          req["X-Api-Token"] = canoe_api_token
          req.form_data = params if method != "GET"

          http.request(req)
        end
      end
      private_class_method :call_api

      def self.canoe_url
        @canoe_url ||= URI(ENV.fetch("CANOE_URL", "https://canoe.dev.pardot.com"))
      end
      private_class_method :canoe_url

      def self.canoe_api_token
        @canoe_api_token ||= ENV.fetch("CANOE_API_TOKEN")
      end
      private_class_method :canoe_api_token
    end
  end
end
