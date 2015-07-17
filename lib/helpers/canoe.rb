require "shell_helper"
require "json"

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

  def self.get_current_build(environment)
    return if !environment.use_canoe?
    result = self.call_api(environment, "api/status/deploy/#{environment.canoe_target}/pardot", method: "GET")
    parsed = JSON.parse(result)
    parsed["what_details"]
  end

  def self.call_api(environment, path, params={})
    params[:method] ||= "POST"
    curl_cmd = "curl -s -X #{params.delete(:method)} #{environment.canoe_url}/#{path}"
    params.merge!(api_token: environment.canoe_api_token)
    params.each { |key, value| curl_cmd << " -d #{key}=\"#{value}\"" }
    ShellHelper.execute_shell(curl_cmd)
  end

end
