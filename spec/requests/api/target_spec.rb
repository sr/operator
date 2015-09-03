require "rails_helper"

RSpec.describe "/api/*/target" do
  before do
    @deploy_target = FactoryGirl.create(:deploy_target)
    @repo = FactoryGirl.create(:repo)
    @user = FactoryGirl.create(:user, email: "sveader@salesforce.com")
    @other_user = FactoryGirl.create(:user)
  end

  describe "/api/status/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        get "/api/status/target/#{@deploy_target.name}"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      it "should require target" do
        api_get "/api/status/target/foo"
        assert_json_error_response("Invalid target")
      end

      it "should indicate if target is locked" do
        @deploy_target.lock!(@other_user)

        api_get "/api/status/target/#{@deploy_target.name}"
        expect(response).to be_ok
        expect(json_response["available"]).to be_falsey
        expect(json_response["reason"]).to include("currently locked")
      end

      it "should indicate if target has an active deploy" do
        deploy = FactoryGirl.create(:deploy, repo_name: @repo.name, deploy_target: @deploy_target, completed: false)

        api_get "/api/status/target/#{@deploy_target.name}"
        expect(response).to be_ok
        expect(json_response["available"]).to be_falsey
        expect(json_response["reason"]).to include("running deploy")
      end

      it "should indicate available if good" do
        api_get "/api/status/target/#{@deploy_target.name}"
        expect(response).to be_ok
        expect(json_response["available"]).to be_truthy
        assert_nil json_response["reason"]
      end
    end
  end

  describe "/api/lock/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        post "/api/lock/target/#{@deploy_target.name}"
        assert_json_error_response("auth token")
      end

      it "should not respond to GET" do
        expect {
          get "/api/lock/target/#{@deploy_target.name}"
        }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "with authentication" do
      it "should require target" do
        api_post "/api/lock/target/foo"
        assert_json_error_response("Invalid target")
      end

      it "should give locking output" do
        api_post "/api/lock/target/#{@deploy_target.name}"
        expect(response).to be_ok
        expect(json_response["locked"]).to be_truthy
        # See Canoe::Deployment::Strategies::Test
        expect(json_response["output"]).to include("test lock successful")
      end
    end
  end

  describe "/api/unlock/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        post "/api/unlock/target/#{@deploy_target.name}"
        assert_json_error_response("auth token")
      end

      it "should not respond to GET" do
        expect {
          get "/api/lock/untarget/#{@deploy_target.name}"
        }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "with authentication" do
      it "should require target" do
        api_post "/api/unlock/target/foo"
        assert_json_error_response("Invalid target")
      end

      it "should give unlocking output" do
        api_post "/api/unlock/target/#{@deploy_target.name}"
        expect(response).to be_ok
        expect(json_response["locked"]).to be_falsey
        # See Canoe::Deployment::Strategies::Test
        expect(json_response["output"]).to include("test unlock successful")
      end
    end
  end

  describe "/api/deploy/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        post "/api/deploy/target/#{@deploy_target.name}"
        assert_json_error_response("auth token")
      end

      it "should not respond to GET" do
        expect {
          get "/api/deploy/target/#{@deploy_target.name}"
        }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "with authentication" do
      it "should require target" do
        api_post "/api/deploy/target/foo"
        assert_json_error_response("Invalid target")
      end

      it "should require repo" do
        api_post "/api/deploy/target/#{@deploy_target.name}"
        assert_json_error_response("Invalid repo")
      end

      it "should indicate when user is unable to deploy (locking error)" do
        @deploy_target.lock!(@other_user)

        expect(Octokit).to receive(:ref).with("Pardot/#{@repo.name}", "tags/build1234").and_return({object: {sha: "abc123"}})
        expect(Octokit).to receive(:tag).with("Pardot/#{@repo.name}", "abc123").and_return({object: {sha: "bcd345"}})

        api_post "/api/deploy/target/#{@deploy_target.name}?repo_name=#{@repo.name}&what=tag&what_details=build1234"
        assert_json_error_response("locked")
      end

      it "should require a branch or tag" do
        api_post "/api/deploy/target/#{@deploy_target.name}?repo_name=#{@repo.name}"
        assert_json_error_response("Unknown deploy type")
      end

      it "should indicate unknown branch" do
        expect(Octokit).to receive(:ref).with("Pardot/#{@repo.name}", "heads/build1234").and_raise(Octokit::NotFound)

        api_post "/api/deploy/target/#{@deploy_target.name}?repo_name=#{@repo.name}&what=branch&what_details=build1234"
        assert_json_error_response("Invalid branch")
      end

      it "should indicate unknown tag" do
        expect(Octokit).to receive(:ref).with("Pardot/#{@repo.name}", "tags/build1234").and_raise(Octokit::NotFound)

        api_post "/api/deploy/target/#{@deploy_target.name}?repo_name=#{@repo.name}&what=tag&what_details=build1234"
        expect(response).to be_ok
        expect(json_response["deployed"]).to be_falsey
        expect(json_response["message"]).to include("Invalid tag")
      end

      it "should indicate deploy and give callback URL" do
        expect(Octokit).to receive(:ref).with("Pardot/#{@repo.name}", "tags/build1234").and_return({object: {sha: "abc123"}})
        expect(Octokit).to receive(:tag).with("Pardot/#{@repo.name}", "abc123").and_return({object: {sha: "bcd345"}})

        api_post "/api/deploy/target/#{@deploy_target.name}?repo_name=#{@repo.name}&what=tag&what_details=build1234"
        expect(response).to be_ok
        expect(json_response["deployed"]).to be_truthy
        expect(json_response["status_callback"]).to match(%r{/api/status/deploy/\d+})
      end
    end
  end
end
