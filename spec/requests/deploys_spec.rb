require "rails_helper"

RSpec.describe "/deploys" do
  describe "#rollback" do
    before do
      @user = FactoryGirl.create(:user)

      @repo = FactoryGirl.create(:repo)
      @deploy_target = FactoryGirl.create(:deploy_target)

      @first_deploy = FactoryGirl.create(:deploy,
        repo_name: @repo.name,
        deploy_target: @deploy_target,
        what: "tag",
        what_details: "build1",
        artifact_url: "https://artifactory.example/build1.tar.gz",
        deploy_target: @deploy_target,
        completed: true,
      )

      @current_deploy = FactoryGirl.create(:deploy,
        repo_name: @repo.name,
        deploy_target: @deploy_target,
        what: "tag",
        what_details: "build2",
        artifact_url: "https://artifactory.example/build2.tar.gz",
        deploy_target: @deploy_target,
        completed: true,
      )
    end

    it "rejects the rollback if the user requests a rollback on a deploy that is not the latest deploy" do
      stub_authentication(@user) and perform_login

      expect {
        post "/repos/#{@repo.name}/deploys/#{@first_deploy.id}/rollback"
      }.not_to change { Deploy.count }

      follow_redirect!
      expect(response.body).to include("Only the latest deploy can be rolled back")
    end

    it "cancels the current deploy and creates a deploy that rollbacks the current deploy" do
      stub_authentication(@user) and perform_login

      expect {
        post "/repos/#{@repo.name}/deploys/#{@current_deploy.id}/rollback"
      }.to change { Deploy.count }.by(1)

      @current_deploy.reload
      expect(@current_deploy.completed).to be_truthy

      rollback_deploy = Deploy.last
      expect(rollback_deploy.repo_name).to eq(@first_deploy.repo_name)
      expect(rollback_deploy.artifact_url).to eq(@first_deploy.artifact_url)
      expect(rollback_deploy.what).to eq(@first_deploy.what)
      expect(rollback_deploy.what_details).to eq(@first_deploy.what_details)
      expect(rollback_deploy.sha).to eq(@first_deploy.sha)

      expect(@deploy_target.most_recent_deploy(@repo)).to eq(rollback_deploy)
    end

    it "rolls back only to the specified servers from the current deploy" do
      # create a scenario where one pull-based server and one sync-based server
      # are used for the deploy
      pull_server = FactoryGirl.create(:server, hostname: "pull-based-server.example")
      pull_server.deploy_scenarios.create!(repo: @repo, deploy_target: @deploy_target)

      stub_authentication(@user) and perform_login
      @current_deploy.update!(
        servers_used: "localhost", # only sync-based servers are saved in servers_used
        specified_servers: "localhost,#{pull_server.hostname}"
      )
      @current_deploy.results.create!(server: pull_server)

      expect {
        post "/repos/#{@repo.name}/deploys/#{@current_deploy.id}/rollback"
      }.to change { Deploy.count }.by(1)

      rollback_deploy = Deploy.last
      expect(rollback_deploy.servers_used).to eq(@current_deploy.servers_used)
      expect(rollback_deploy.specified_servers).to eq(@current_deploy.specified_servers)
      expect(rollback_deploy.results.length).to eq(1)
      expect(rollback_deploy.results[0].server).to eq(pull_server)
    end
  end
end
