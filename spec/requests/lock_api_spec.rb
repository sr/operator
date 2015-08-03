require "rails_helper"

RSpec.describe "/api/lock" do
  describe "/api/lock/status" do
    describe "without authentication" do
      it "should error" do
        get "/api/lock/status"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      it "should return status of lock from web" do
        email = "sveader@salesforce.com"
        target_mock = DeployTarget.new(name: "test")
        expect(target_mock).to receive(:locking_user).and_return(OpenStruct.new(email: email))
        expect(target_mock).to receive(:is_locked?).and_return(true)
        expect(target_mock).to receive(:has_file_lock?).and_return(false)
        expect(DeployTarget).to receive(:order).with(:name).and_return([target_mock])

        api_get "/api/lock/status"
        assert_nonerror_response
        assert json_response["test"]
        assert json_response["test"]["locked"]
        assert_equal email, json_response["test"]["locked_by"]
      end

      it "should return status of lock on filesystem" do
        username = "sv"
        target_mock = DeployTarget.new(name: "test")
        expect(target_mock).to receive(:is_locked?).and_return(true)
        expect(target_mock).to receive(:has_file_lock?).and_return(true)
        expect(target_mock).to receive(:file_lock_user).and_return(username)
        expect(DeployTarget).to receive(:order).with(:name).and_return([target_mock])

        api_get "/api/lock/status"
        assert_nonerror_response
        assert json_response["test"]
        assert json_response["test"]["locked"]
        assert_equal username, json_response["test"]["locked_by"]
      end

      it "should error if ENV setting is not defined for auth token" do
        # one test to make sure we are confirming API token isn't nil
        #     (ie: new or unchanged config on server)
        before_token = ENV["API_AUTH_TOKEN"]
        ENV["API_AUTH_TOKEN"] = nil
        api_get "/api/lock/status"
        assert_json_error_response("auth token")
        ENV["API_AUTH_TOKEN"] = before_token # put it back
      end
    end
  end
end
