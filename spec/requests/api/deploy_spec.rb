require "rails_helper"

RSpec.describe "/api/deploy" do
  describe "/api/deploy/:deploy_id/completed_server" do
    describe "without authentication" do
      it "should error" do
        post "/api/deploy/1/completed_server"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      it "should set empty list to a single server" do
        repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
        deploy = FactoryGirl.create(:deploy, repo_name: repo.name)

        api_post "/api/deploy/#{deploy.id}/completed_server", { server: "test-server" }

        expect(Deploy.find(deploy.id).completed_servers).to eq("test-server")
        assert_nonerror_response
      end

      context "sync_script servers" do
        it "should add to existing list of servers" do
          repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
          deploy = FactoryGirl.create(:deploy, repo_name: repo.name, completed_servers: "foo,bar")
          
          api_post "/api/deploy/#{deploy.id}/completed_server", { server: "test-server" }
          expect(Deploy.find(deploy.id).completed_servers).to eq("foo,bar,test-server")

          assert_nonerror_response
        end
      end

      context "pull_agent servers" do
        it "updates the deploy result record for the server" do
          repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
          server = FactoryGirl.create(:server)
          deploy = FactoryGirl.create(:deploy, repo_name: repo.name)
          result = deploy.results.create!(server: server)

          api_post "/api/deploy/#{deploy.id}/completed_server", { server: server.hostname }
          assert_nonerror_response

          result.reload
          expect(result.stage).to eq("completed")
        end
      end
    end
  end
end
