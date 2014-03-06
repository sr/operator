require File.join(File.dirname(__FILE__), "test_helper.rb")

describe Canoe do
  include Rack::Test::Methods

  def app
    CanoeApplication
  end

  describe "accessing /api/lock/status" do
    it "should return status of lock from web" do
      email = "sveader@salesforce.com"
      target_mock = DeployTarget.new(name: "test")
      target_mock.expects(:locking_user).returns(OpenStruct.new(email: email))
      target_mock.expects(:is_locked?).returns(true)
      target_mock.expects(:has_file_lock?).returns(false)
      DeployTarget.expects(:order).with(:name).returns([target_mock])

      get "/api/lock/status"
      assert_nonerror_response
      assert json_response["test"]
      assert json_response["test"]["locked"]
      assert_equal email, json_response["test"]["locked_by"]
    end

    it "should return status of lock on filesystem" do
      username = "sv"
      target_mock = DeployTarget.new(name: "test")
      target_mock.expects(:locking_user).returns(nil)
      target_mock.expects(:is_locked?).returns(true)
      target_mock.expects(:has_file_lock?).returns(true)
      target_mock.expects(:file_lock_user).returns(username)
      DeployTarget.expects(:order).with(:name).returns([target_mock])

      get "/api/lock/status"
      assert_nonerror_response
      assert json_response["test"]
      assert json_response["test"]["locked"]
      assert_equal username, json_response["test"]["locked_by"]
    end
  end

end
