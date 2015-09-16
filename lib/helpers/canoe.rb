require "net/http"
require "json"
require "deploy"

class Canoe
  #def self.notify(environment)
  #  return if !environment.use_canoe? || environment.deploy_id.nil?
  #  self.call_api(environment, "api/deploy/#{environment.deploy_id}/complete")
  #end
#
  #def self.notify_completed_server(environment, server)
  #  return if !environment.use_canoe? || environment.deploy_id.nil?
  #  self.call_api(environment, "api/deploy/#{environment.deploy_id}/completed_server", server: server)
  #end

  def self.latest_deploy(environment)
    return if !environment.use_canoe?
    result = call_api(environment, "POST", "/api/targets/#{environment.canoe_target}/deploys/latest", repo_name: environment.payload.id)

    json = JSON.parse(result.body)
    Deploy.new(
      json["what"],
      json["what_details"],
      json["build_number"],
      json["artifact_url"],
      json["servers"]
    )
  end

  def self.call_api(environment, method, path, params={})
    canoe_url = URI(environment.canoe_url)
    response = Net::HTTP.start(canoe_url.host, canoe_url.port, use_ssl: (canoe_url.scheme == "https")) do |http|
      req = case method
            when "POST" then Net::HTTP::Post.new(path)
            when "GET" then Net::HTTP::Get.new(path)
            end
      req.form_data = params.merge(api_token: environment.canoe_api_token)

      http.request(req)
    end
  end
  private_class_method :call_api
end
