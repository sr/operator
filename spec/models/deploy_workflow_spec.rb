require "rails_helper"

RSpec.describe DeployWorkflow do
  let(:repo) { FactoryGirl.create(:repo) }
  let(:deploy) { FactoryGirl.create(:deploy, repo_name: repo.name) }

  context "initiating a deploy" do
    it "creates a deploy result for each server, initially setting them to stage: initiated" do
      servers = FactoryGirl.create_list(:server, 3)

      workflow = DeployWorkflow.initiate(deploy: deploy, servers: servers)
      expect(deploy.results.length).to eq(3)
    end
  end

  context "initiated -> deployed" do
    it "assigns the first server to be successful at deploying code as the restart server" do
      servers = FactoryGirl.create_list(:server, 3)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: servers)

      server = servers.first
      workflow.notify_action_successful(server: server, action: "deploy")

      deploy.reload
      expect(deploy.results.for_server(server).stage).to eq("deployed")
      expect(deploy.restart_server).to eq(server)
    end
  end

  context "initiated -> completed" do
    it "moves servers other than the restart server to the completed state" do
      servers = FactoryGirl.create_list(:server, 3)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: servers)

      restart_server = servers.first
      workflow.notify_action_successful(server: restart_server, action: "deploy")

      second_server = servers[1]
      workflow.notify_action_successful(server: second_server, action: "deploy")
      expect(deploy.results.for_server(second_server).stage).to eq("completed")

      third_server = servers[2]
      workflow.notify_action_successful(server: third_server, action: "deploy")
      expect(deploy.results.for_server(third_server).stage).to eq("completed")
    end
  end
end
