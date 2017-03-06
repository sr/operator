require "rails_helper"

RSpec.describe "/targets/:target_name/deploys/:deploy_id/results/:server_hostname" do
  let(:target) { FactoryGirl.create(:deploy_target) }
  let(:project) { FactoryGirl.create(:project) }
  let(:deploy) { FactoryGirl.create(:deploy, deploy_target: target, project_name: project.name, completed: false) }
  let(:server) { FactoryGirl.create(:server) }

  before do
    deploy.results.create!(server: server, stage: "initiated")
    deploy.deploy_restart_servers.create!(datacenter: server.datacenter)
  end

  describe "PUT #update" do
    it "transitions the server from the initiated stage to the deployed stage after successful completion of 'deploy'" do
      api_put "/api/targets/#{target.name}/deploys/#{deploy.id}/results/#{server.hostname}", success: true, action: "deploy"
      expect(response.status).to eq(303)

      api_get response.location
      expect(response.status).to eq(200)
      expect(json_response["servers"][server.hostname]["stage"]).to eq("deployed")
    end

    it "transitions the server from the deployed stage to the completed stage after successful completion of 'restart'" do
      deploy.results.for_server(server).update(stage: "deployed")

      api_put "/api/targets/#{target.name}/deploys/#{deploy.id}/results/#{server.hostname}", success: true, action: "restart"
      expect(response.status).to eq(303)

      api_get response.location
      expect(response.status).to eq(200)
      expect(json_response["servers"][server.hostname]["stage"]).to eq("completed")
    end

    it "returns a 400 error if the action is not a valid transition for the current stage" do
      api_put "/api/targets/#{target.name}/deploys/#{deploy.id}/results/#{server.hostname}", success: true, action: "restart"
      expect(response.status).to eq(400)
      expect(json_response["error"]).to match(/transition/)
    end
  end
end
