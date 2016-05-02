require "rails_helper"

RSpec.describe DeployWorkflow do
  let(:repo) { FactoryGirl.create(:repo) }
  let(:deploy) { FactoryGirl.create(:deploy, completed: false, repo_name: repo.name) }

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
      expect(deploy.restart_servers).to eq([server])
    end
  end

  context "initiated -> completed" do
    it "moves servers other than the restart server to the completed stage" do
      servers = FactoryGirl.create_list(:server, 3)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: servers)

      restart_server = servers.first
      workflow.notify_action_successful(server: restart_server, action: "deploy")

      server2 = servers[1]
      workflow.notify_action_successful(server: server2, action: "deploy")
      expect(deploy.results.for_server(server2).stage).to eq("completed")

      server3 = servers[2]
      workflow.notify_action_successful(server: server3, action: "deploy")
      expect(deploy.results.for_server(server3).stage).to eq("completed")
    end

    it "there should be one restart server per datacenter" do
      servers = FactoryGirl.create_list(:server, 2)
      servers << FactoryGirl.create(:server, hostname: "bastion-dfw")
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: servers)

      server1 = servers.first
      workflow.notify_action_successful(server: server1, action: "deploy")
      expect(deploy.results.for_server(server1).stage).to eq("deployed")
      
      server2 = servers[1]
      workflow.notify_action_successful(server: server2, action: "deploy")
      expect(deploy.results.for_server(server2).stage).to eq("completed")

      server3 = servers[2]
      workflow.notify_action_successful(server: server3, action: "deploy")
      expect(deploy.results.for_server(server3).stage).to eq("deployed")
    end
  end

  context "deployed -> completed" do
    it "moves the restart server to the completed stage after it reports a successful restart" do
      servers = FactoryGirl.create_list(:server, 3)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: servers)

      restart_server = servers.first
      workflow.notify_action_successful(server: restart_server, action: "deploy")
      workflow.notify_action_successful(server: restart_server, action: "restart")

      expect(deploy.results.for_server(restart_server).stage).to eq("completed")
    end

    it "moves the entire deploy to be completed when all results are completed" do
      restart_server, other_server = FactoryGirl.create_list(:server, 2)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [restart_server, other_server])

      workflow.notify_action_successful(server: restart_server, action: "deploy")
      workflow.notify_action_successful(server: other_server, action: "deploy")
      workflow.notify_action_successful(server: restart_server, action: "restart")

      deploy.reload
      expect(deploy.completed).to be_truthy
    end
  end

  context "invalid transition" do
    it "raises a TransitionError" do
      server = FactoryGirl.create(:server)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [server])

      expect {
        workflow.notify_action_successful(server: server, action: "restart")
      }.to raise_error(DeployWorkflow::TransitionError)
    end
  end

  describe "#next_action_for" do
    it "is nil if the deploy is completed for any reason (e.g., being canceled)" do
      server = FactoryGirl.create(:server)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [server])

      deploy.cancel!
      expect(workflow.next_action_for(server: server)).to eq(nil)
    end

    it "is deploy for any server in the initiated stage" do
      server = FactoryGirl.create(:server)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [server])

      expect(deploy.results.for_server(server).stage).to eq("initiated")
      expect(workflow.next_action_for(server: server)).to eq("deploy")
    end

    it "is nil for a restart server if there are still servers that have not yet deployed the code" do
      restart_server, other_server = FactoryGirl.create_list(:server, 2)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [restart_server, other_server])

      workflow.notify_action_successful(server: restart_server, action: "deploy")

      expect(deploy.results.for_server(restart_server).stage).to eq("deployed")
      expect(workflow.next_action_for(server: restart_server)).to eq(nil)
    end

    it "is restart for the restart server after all of the servers have deployed code" do
      restart_server, other_server = FactoryGirl.create_list(:server, 2)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [restart_server, other_server])

      workflow.notify_action_successful(server: restart_server, action: "deploy")
      workflow.notify_action_successful(server: other_server, action: "deploy")

      expect(deploy.results.for_server(restart_server).stage).to eq("deployed")
      expect(workflow.next_action_for(server: restart_server)).to eq("restart")
    end
  end

  describe "#fail_deploy_on_initiated_servers" do
    it "moves any servers in the initiated stage to the failed stage" do
      server = FactoryGirl.create(:server)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [server])

      workflow.fail_deploy_on_initiated_servers
      expect(deploy.results.for_server(server).stage).to eq("failed")
      expect(deploy.completed?).to be_truthy
    end

    it "allows the restart phase to proceed" do
      restart_server, other_server = FactoryGirl.create_list(:server, 2)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [restart_server, other_server])

      workflow.notify_action_successful(server: restart_server, action: "deploy")
      workflow.fail_deploy_on_initiated_servers

      expect(deploy.completed?).to be_falsey
      expect(workflow.next_action_for(server: restart_server)).to eq("restart")

      workflow.notify_action_successful(server: restart_server, action: "restart")

      expect(deploy.completed?).to be_truthy
    end
  end

  describe "#fail_deploy_on_incomplete_servers" do
    it "moves any servers in the incomplete stage to the failed stage" do
      server = FactoryGirl.create(:server)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [server])

      workflow.fail_deploy_on_incomplete_servers
      expect(deploy.results.for_server(server).stage).to eq("failed")
      expect(deploy.completed?).to be_truthy
    end

    it "skips the restart phase" do
      restart_server, other_server = FactoryGirl.create_list(:server, 2)
      workflow = DeployWorkflow.initiate(deploy: deploy, servers: [restart_server, other_server])

      workflow.notify_action_successful(server: restart_server, action: "deploy")
      workflow.fail_deploy_on_incomplete_servers

      expect(workflow.next_action_for(server: restart_server)).to eq(nil)
      expect(deploy.completed?).to be_truthy
    end
  end
end