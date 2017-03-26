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
      it "updates the deploy result record for the server" do
        project = FactoryGirl.create(:project) # TODO: Remove this when we've added an association btw Deploy & Project
        server = FactoryGirl.create(:server)
        deploy = FactoryGirl.create(:deploy, project_name: project.name)
        result = deploy.results.create!(server: server)

        api_post "/api/deploy/#{deploy.id}/completed_server", server: server.hostname
        assert_nonerror_response

        result.reload
        expect(result.stage).to eq("completed")
      end
    end
  end
end
