require "net/http"
require "json"
require "deploy"

class Canoe
  def self.notify_completed_server(environment, deploy, server)
    return if !environment.use_canoe?
    call_api(environment, "POST", "/api/deploy/#{deploy.id}/completed_server", server: server)
  end

  def self.latest_deploy(environment)
    return if !environment.use_canoe?
    result = call_api(environment, "POST", "/api/targets/#{environment.canoe_target}/deploys/latest", repo_name: environment.payload.id)

    json = JSON.parse(result.body)
    Deploy.from_hash(json)
  end

  def self.call_api(environment, method, path, params={})
    canoe_url = URI(environment.canoe_url)
    Net::HTTP.start(canoe_url.host, canoe_url.port, use_ssl: (canoe_url.scheme == "https")) do |http|
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
