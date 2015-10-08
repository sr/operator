require_relative "test_helper.rb"
require "canoe"
require "environment_test"
require "console"
require "shell_helper"

describe Canoe do
  before {
    Console.silence!
    @env = EnvironmentTest.new
    @env.payload = "pardot"
  }

  describe ".latest_deploy" do
    it "fetches the latest deploy from the Canoe API" do
      stub_request(:post, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest")
        .with(body: {api_token: @env.canoe_api_token, repo_name: @env.payload.id.to_s})
        .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"http://artifactory.example/build1234.tar.gz","build_number":1234,"action":null,"servers":["localhost"]}))

      deploy = Canoe.latest_deploy(@env)
      deploy.id.must_equal 445
      deploy.what.must_equal "branch"
      deploy.what_details.must_equal "master"
      deploy.artifact_url.must_equal "http://artifactory.example/build1234.tar.gz"
      deploy.build_number.must_equal 1234
      deploy.action.must_equal nil
      deploy.servers.must_equal ["localhost"]
    end
  end

  describe ".notify_server" do
    it "reports that the server has completed its deployment" do
      deploy = Deploy.from_hash("id" => 445, "action" => "deploy")
      stub_request(:post, "#{@env.canoe_url}/api/deploy/#{deploy.id}")
        .with(body: {api_token: @env.canoe_api_token, server: ShellHelper.hostname, action: "deploy", success: "true"})
        .to_return(body: %({"success": true}))

      Canoe.notify_server(@env, deploy)
    end
  end
end
