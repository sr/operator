require "net/http"
require "cgi"
require "json"
require "deploy"

class Canoe
  def self.notify_server(environment, deploy)
    return if !environment.use_canoe?
    call_api(environment, "PUT", "/api/targets/#{environment.canoe_target}/deploys/#{deploy.id}/results/#{ShellHelper.hostname}", action: deploy.action, success: true)
  end

  def self.latest_deploy(environment)
    return if !environment.use_canoe?
    result = call_api(environment, "GET", "/api/targets/#{environment.canoe_target}/deploys/latest", repo_name: environment.payload.id, server: ShellHelper.hostname)

    json = JSON.parse(result.body)
    Deploy.from_hash(json)
  end

  def self.call_api(environment, method, path, params={})
    canoe_url = URI(environment.canoe_url)
    Net::HTTP.start(canoe_url.host, canoe_url.port, use_ssl: (canoe_url.scheme == "https")) do |http|
      if method == "GET" && !params.empty?
        path += "?" + params.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
      end
      req = case method
            when "POST" then Net::HTTP::Post.new(path)
            when "GET" then Net::HTTP::Get.new(path)
            when "PUT" then Net::HTTP::Put.new(path)
            end
      req['X-Api-Token'] = environment.canoe_api_token
      req.form_data = params if method != "GET" && !params.empty?

      http.request(req)
    end
  end
  private_class_method :call_api
end
