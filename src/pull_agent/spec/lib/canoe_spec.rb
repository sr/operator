require "spec_helper"

describe PullAgent::Canoe do
  describe ".latest_deploy" do
    it "fetches the latest deploy from the Canoe API" do
      stub_request(:get, "#{ENV["CANOE_URL"]}/api/targets/dev/deploys/latest?repo_name=pardot&server=#{PullAgent::ShellHelper.hostname}")
        .to_return(body: %({"id":445,"branch":"master","artifact_url":"http://artifactory.example/build1234.tar.gz","build_number":1234,"servers":{"localhost":{"stage":"completed","action":null}}}))

      deploy = PullAgent::Canoe.latest_deploy("dev", "pardot")
      expect(deploy.id).to eq(445)
      expect(deploy.branch).to eq("master")
      expect(deploy.artifact_url).to eq("http://artifactory.example/build1234.tar.gz")
      expect(deploy.build_number).to eq(1234)
      expect(deploy.server_actions).to be_instance_of(Hash)
    end
  end

  describe ".notify_server" do
    it "reports that the server has completed its deployment" do
      deploy = PullAgent::Deploy.from_hash("id" => 445, "servers" => { PullAgent::ShellHelper.hostname => { "action" => "deploy" } })
      stub_request(:put, "#{ENV["CANOE_URL"]}/api/targets/dev/deploys/#{deploy.id}/results/#{PullAgent::ShellHelper.hostname}")
        .with(body: { action: "deploy", success: "true" })
        .to_return(body: %({"success": true}))

      PullAgent::Canoe.notify_server("dev", deploy)
    end
  end
end
