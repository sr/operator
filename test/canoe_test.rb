require_relative "test_helper"
require "canoe"

describe Canoe do
  before {
    Console.silence!
    @env = EnvironmentTest.new
    @env.payload = "pardot"
  }

  describe ".latest_deploy" do
    it "fetches the latest deploy from the Canoe API" do
      stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
        .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"http://artifactory.example/build1234.tar.gz","build_number":1234,"servers":{"localhost":{"stage":"completed","action":null}}}))

      deploy = Canoe.latest_deploy(@env)
      deploy.id.must_equal 445
      deploy.what.must_equal "branch"
      deploy.what_details.must_equal "master"
      deploy.artifact_url.must_equal "http://artifactory.example/build1234.tar.gz"
      deploy.build_number.must_equal 1234
      deploy.server_actions.must_be_instance_of Hash
    end
  end

  describe ".notify_server" do
    it "reports that the server has completed its deployment" do
      deploy = Deploy.from_hash("id" => 445, "servers" => {ShellHelper.hostname => {"action" => "deploy" }})
      stub_request(:put, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/#{deploy.id}/results/#{ShellHelper.hostname}")
        .with(body: {action: "deploy", success: "true"})
        .to_return(body: %({"success": true}))

      Canoe.notify_server(@env, deploy)
    end
  end
end
