require "canoe"
require "environments"

describe Canoe do
  let(:env) {
    Environments.build(:test).tap { |e| e.payload = "pardot" }
  }

  describe ".latest_deploy" do
    it "fetches the latest deploy from the Canoe API" do
      stub_request(:get, "#{env.canoe_url}/api/targets/#{env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
        .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"http://artifactory.example/build1234.tar.gz","build_number":1234,"servers":{"localhost":{"stage":"completed","action":null}}}))

      deploy = Canoe.latest_deploy(env)
      expect(deploy.id).to eq(445)
      expect(deploy.what).to eq("branch")
      expect(deploy.what_details).to eq("master")
      expect(deploy.artifact_url).to eq("http://artifactory.example/build1234.tar.gz")
      expect(deploy.build_number).to eq(1234)
      expect(deploy.server_actions).to be_instance_of(Hash)
    end
  end

  describe ".notify_server" do
    it "reports that the server has completed its deployment" do
      deploy = Deploy.from_hash("id" => 445, "servers" => {ShellHelper.hostname => {"action" => "deploy" }})
      stub_request(:put, "#{env.canoe_url}/api/targets/#{env.canoe_target}/deploys/#{deploy.id}/results/#{ShellHelper.hostname}")
        .with(body: {action: "deploy", success: "true"})
        .to_return(body: %({"success": true}))

      Canoe.notify_server(env, deploy)
    end
  end
end
