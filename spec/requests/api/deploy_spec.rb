require "rails_helper"

RSpec.describe "/api/deploy" do
  describe "/api/deploy/:deploy_id/complete" do
    describe "without authentication" do
      it "should error" do
        post "/api/deploy/1/complete"
        assert_json_error_response(/auth token/)
      end
    end

    describe "with authentication" do
      it "should mark deploy as completed" do
        define_deploy_mock(2) do |deploy_mock|
          expect(deploy_mock).to receive(:complete!)
        end

        api_post "/api/deploy/2/complete"
        assert_nonerror_response
      end
    end
  end

  describe "/api/deploy/:deploy_id/completed_server" do
    describe "without authentication" do
      it "should error" do
        post "/api/deploy/1/completed_server"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      it "should set empty list to a single server" do
        define_deploy_mock(2) do |deploy_mock|
          allow(deploy_mock).to receive(:completed_servers).and_return(nil)
          expect(deploy_mock).to receive(:update_attribute).with(:completed_servers, "test-server")
        end

        api_post "/api/deploy/2/completed_server", { server: "test-server" }
        assert_nonerror_response
      end

      it "should add to existing list of servers" do
        define_deploy_mock(3) do |deploy_mock|
          allow(deploy_mock).to receive(:completed_servers).and_return("foo,bar")
          expect(deploy_mock).to receive(:update_attribute).with(:completed_servers, "foo,bar,test-server")
        end

        api_post "/api/deploy/3/completed_server", { server: "test-server" }
        assert_nonerror_response
      end
    end
  end

  describe "/api/status/deploy/:deploy_id" do
    describe "without authentication" do
      it "should error" do
        get "/api/status/deploy/1"
        assert_json_error_response("auth token")
      end

      it "should not respond to POST" do
        expect {
          post "/api/status/deploy/1"
        }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "with authentication" do
      it "should require target" do
        expect(Deploy).to receive(:find_by_id).with(1).and_return(nil)

        api_get "/api/status/deploy/1"
        assert_json_error_response("Unable to find")
      end

      it "should give info on status of deploy" do
        deploy = Deploy.new(id: 1, what: "tag", what_details: "1234", completed: true)
        expect(deploy).to receive(:deploy_target).and_return(OpenStruct.new(name: "test"))
        expect(deploy).to receive(:auth_user).and_return(OpenStruct.new(email: "sveader@salesforce.com"))
        # expect(deploy).to receive(:repo).and_return(OpenStruct.new(name: "pardot"))

        expect(Deploy).to receive(:find_by_id).with(1).and_return(deploy)

        api_get "/api/status/deploy/1"
        expect(response).to be_ok
        expect(json_response["completed"]).to be_truthy
      end
    end
  end # /api/status/deploy
end
