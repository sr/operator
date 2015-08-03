require "rails_helper"

RSpec.describe "/api/*/target" do
  describe "/api/status/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        get "/api/status/target/test"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      it "should require target" do
        define_target_missing_mock("foo")
        api_get "/api/status/target/foo"
        assert_json_error_response("Invalid target")
      end

      it "should require user" do
        define_api_user_missing_mock
        define_target_mock
        api_get "/api/status/target/test"
        assert_json_error_response("Invalid user")
      end

      it "should indicate if target is locked" do
        define_api_user_mock
        define_target_mock do |target_mock|
          expect(target_mock).to receive(:user_can_deploy?).and_return(false)
          expect(target_mock).to receive(:name_of_locking_user).and_return("sveader@salesforce.com")
        end

        api_get "/api/status/target/test"
        expect(response).to be_ok
        expect(json_response["available"]).to be_falsey
        expect(json_response["reason"]).to include("currently locked")
      end

      it "should indicate if target has an active deploy" do
        define_api_user_mock
        define_target_mock do |target_mock|
          expect(target_mock).to receive(:user_can_deploy?).and_return(true)
          deploy_mock = \
            OpenStruct.new(repo_name: "foo", what: "tag", what_details: "1234")
          allow(target_mock).to receive(:active_deploy).and_return(deploy_mock)
        end

        api_get "/api/status/target/test"
        expect(response).to be_ok
        expect(json_response["available"]).to be_falsey
        expect(json_response["reason"]).to include("running deploy")
      end

      it "should indicate available if good" do
        define_api_user_mock
        define_target_mock do |target_mock|
          expect(target_mock).to receive(:user_can_deploy?).and_return(true)
          allow(target_mock).to receive(:active_deploy).and_return(nil)
        end

        api_get "/api/status/target/test"
        expect(response).to be_ok
        expect(json_response["available"]).to be_truthy
        assert_nil json_response["reason"]
      end
    end
  end

  describe "/api/lock/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        post "/api/lock/target/test"
        assert_json_error_response("auth token")
      end

      it "should not respond to GET" do
        expect {
          get "/api/lock/target/test"
        }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "with authentication" do
      it "should require target" do
        define_target_missing_mock("foo")
        api_post "/api/lock/target/foo"
        assert_json_error_response("Invalid target")
      end

      it "should require user" do
        define_api_user_missing_mock
        define_target_mock
        api_post "/api/lock/target/test"
        assert_json_error_response("Invalid user")
      end

      it "should give locking output" do
        define_api_user_mock
        define_target_mock do |target_mock|
          # make sure shell command just echos and exits
          expect(target_mock).to receive(:script_path).and_return("~; echo 'test'; exit 0;")
          expect(target_mock).to receive(:lock!)
          expect(target_mock).to receive(:reload)
          expect(target_mock).to receive(:is_locked?).and_return(true)
        end

        api_post "/api/lock/target/test"
        expect(response).to be_ok
        expect(json_response["locked"]).to be_truthy
        # make sure output is pushed into json response
        expect(json_response["output"]).to include("test")
      end
    end
  end

  describe "/api/unlock/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        post "/api/unlock/target/test"
        assert_json_error_response("auth token")
      end

      it "should not respond to GET" do
        expect {
          get "/api/lock/untarget/test"
        }.to raise_error(ActionController::RoutingError)
      end
    end

    describe "with authentication" do
      it "should require target" do
        define_target_missing_mock("foo")
        api_post "/api/unlock/target/foo"
        assert_json_error_response("Invalid target")
      end

      it "should require user" do
        define_api_user_missing_mock
        define_target_mock
        api_post "/api/unlock/target/test"
        assert_json_error_response("Invalid user")
      end

      it "should give unlocking output" do
        define_api_user_mock
        define_target_mock do |target_mock|
          # make sure shell command just echos and exits
          expect(target_mock).to receive(:script_path).and_return("~; echo 'test'; exit 0;")
          expect(target_mock).to receive(:unlock!)
          expect(target_mock).to receive(:reload)
          expect(target_mock).to receive(:is_locked?).and_return(false)
        end

        api_post "/api/unlock/target/test"
        expect(response.ok?).to be_truthy
        expect(json_response["locked"]).to be_falsey
        # make sure output is pushed into json response
        expect(json_response["output"]).to include("test")
      end
    end
  end
end
