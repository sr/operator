require "rails_helper"

RSpec.describe Canoe::Deployer do
  describe "#deploys" do
    context "testing all server defaults" do
      let(:deployer) { Canoe::Deployer.new }
      let(:deploy_scenario) { FactoryGirl.create(:deploy_scenario) }
      let(:prov_deploy) do
        ProvisionalDeploy.new(
          project: deploy_scenario.project,
          artifact_url: "https://dev.pardot.com/123",
          what: "commit",
          what_details: "abc123",
          build_number: 1234,
          sha: "abc123",
          passed_ci: true
        )
      end
      let(:user) { FactoryGirl.create(:user) }

      it "no servers are specified but we want to default to all servers" do
        deploy = deployer.deploy(
          user: user, 
          what: prov_deploy.what, 
          what_details: prov_deploy.what_details, 
          sha: prov_deploy.sha, 
          passed_ci: prov_deploy.passed_ci,
          target: deploy_scenario.deploy_target,
          project: deploy_scenario.project,
          server_hostnames: false
        )

        expect(deploy.results.count).to eq 1
      end

      it "no servers specified, but have no default to all servers set" do
        not_all_servers = FactoryGirl.create(:project, all_servers_default: false)
        new_deploy_scenario = FactoryGirl.create(:deploy_scenario, project: not_all_servers)
        deploy = deployer.deploy(
          user: user, 
          what: prov_deploy.what, 
          what_details: prov_deploy.what_details, 
          sha: prov_deploy.sha, 
          passed_ci: prov_deploy.passed_ci,
          target: new_deploy_scenario.deploy_target,
          project: new_deploy_scenario.project,
          server_hostnames: false
        )

        expect(deploy.results.count).to eq 0
      end
    end
  end
end