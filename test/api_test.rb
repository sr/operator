require File.join(File.dirname(__FILE__), "test_helper.rb")

describe Canoe do
  include Rack::Test::Methods

  def app
    CanoeApplication
  end

  # --------------------------------------------------------------------------
  describe "accessing /api/lock/status" do
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
        target_mock.expects(:locking_user).returns(OpenStruct.new(email: email))
        target_mock.expects(:is_locked?).returns(true)
        target_mock.expects(:has_file_lock?).returns(false)
        DeployTarget.expects(:order).with(:name).returns([target_mock])

        api_get "/api/lock/status"
        assert_nonerror_response
        assert json_response["test"]
        assert json_response["test"]["locked"]
        assert_equal email, json_response["test"]["locked_by"]
      end

      it "should return status of lock on filesystem" do
        username = "sv"
        target_mock = DeployTarget.new(name: "test")
        target_mock.expects(:is_locked?).returns(true)
        target_mock.expects(:has_file_lock?).returns(true)
        target_mock.expects(:file_lock_user).returns(username)
        DeployTarget.expects(:order).with(:name).returns([target_mock])

        api_get "/api/lock/status"
        assert_nonerror_response
        assert json_response["test"]
        assert json_response["test"]["locked"]
        assert_equal username, json_response["test"]["locked_by"]
      end
    end
  end # /api/lock/status

  # --------------------------------------------------------------------------
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
          target_mock.expects(:user_can_deploy?).returns(false)
          target_mock.expects(:name_of_locking_user).returns("sveader@salesforce.com")
        end

        api_get "/api/status/target/test"
        assert last_response.ok?
        assert !json_response["available"]
        assert_match "currently locked", json_response["reason"]
      end

      it "should indicate if target has an active deploy" do
        define_api_user_mock
        define_target_mock do |target_mock|
          target_mock.expects(:user_can_deploy?).returns(true)
          deploy_mock = \
            OpenStruct.new(repo_name: "foo", what: "tag", what_details: "1234")
          target_mock.stubs(:active_deploy).returns(deploy_mock)
        end

        api_get "/api/status/target/test"
        assert last_response.ok?
        assert !json_response["available"]
        assert_match "running deploy", json_response["reason"]
      end

      it "should indicate available if good" do
        define_api_user_mock
        define_target_mock do |target_mock|
          target_mock.expects(:user_can_deploy?).returns(true)
          target_mock.stubs(:active_deploy).returns(nil)
        end

        api_get "/api/status/target/test"
        assert last_response.ok?
        assert json_response["available"]
        assert_nil json_response["reason"]
      end
    end
  end # /api/status/target

  # --------------------------------------------------------------------------
  describe "/api/lock/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        post "/api/lock/target/test"
        assert_json_error_response("auth token")
      end

      it "should not respond to GET" do
        get "/api/lock/target/test"
        assert last_response.not_found?
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
          target_mock.expects(:script_path).returns("echo 'test'; exit 0;")
          target_mock.expects(:lock!)
          target_mock.expects(:reload!)
          target_mock.expects(:is_locked?).returns(true)
        end

        api_post "/api/lock/target/test"
        assert last_response.ok?
        assert json_response["locked"]
        # make sure output is pushed into json response
        assert_match "test", json_response["output"]
      end
    end
  end # /api/lock/target


end
