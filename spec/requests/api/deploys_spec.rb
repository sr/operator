require "rails_helper"

RSpec.describe "/api/targets/:target_name/deploys" do
  before do
    @target = FactoryGirl.create(:deploy_target, name: "test")
  end

  describe "/api/targets/:target_name/deploys/latest" do
    describe "without authentication" do
      it "should error" do
        post "/api/targets/#{@target.name}/deploys/latest"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      describe "without repo_name" do
        it "should error" do
          api_post "/api/targets/#{@target.name}/deploys/latest", { }
          assert_json_error_response("Invalid repo")
        end
      end

      describe "with a bogus repo name" do
        it "should error" do
          api_post "/api/targets/#{@target.name}/deploys/latest", { repo_name: "foobar" }
          assert_json_error_response("Invalid repo")
        end
      end

      describe "with a good repo name" do
        before do
          @repo = FactoryGirl.create(:repo)
        end

        it "should list the latest deploy info" do
          deploy = FactoryGirl.create(:deploy, repo_name: @repo.name, deploy_target: @target)

          api_post "/api/targets/test/deploys/latest", { repo_name: @repo.name }
          assert_nonerror_response
        end
      end
    end
  end
end
