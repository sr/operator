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

  # --------------------------------------------------------------------------
  describe "/api/unlock/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        post "/api/unlock/target/test"
        assert_json_error_response("auth token")
      end

      it "should not respond to GET" do
        get "/api/unlock/target/test"
        assert last_response.not_found?
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
          target_mock.expects(:script_path).returns("echo 'test'; exit 0;")
          target_mock.expects(:unlock!)
          target_mock.expects(:reload!)
          target_mock.expects(:is_locked?).returns(false)
        end

        api_post "/api/unlock/target/test"
        assert last_response.ok?
        assert !json_response["locked"]
        # make sure output is pushed into json response
        assert_match "test", json_response["output"]
      end
    end
  end # /api/unlock/target

  # --------------------------------------------------------------------------
  describe "/api/deploy/target/:target_name" do
    describe "without authentication" do
      it "should error" do
        post "/api/deploy/target/test"
        assert_json_error_response("auth token")
      end

      it "should not respond to GET" do
        get "/api/deploy/target/test"
        assert last_response.not_found?
      end
    end

    describe "with authentication" do
      it "should require target" do
        define_target_missing_mock("foo")
        api_post "/api/deploy/target/foo"
        assert_json_error_response("Invalid target")
      end

      it "should require user" do
        define_api_user_missing_mock
        define_target_mock
        api_post "/api/deploy/target/test"
        assert_json_error_response("Invalid user")
      end

      it "should require repo" do
        define_api_user_mock
        define_target_mock
        api_post "/api/deploy/target/test"
        assert_json_error_response("Invalid repo")
      end

      it "should indicate when user is unable to deploy (locking error)" do
        define_api_user_mock
        define_repo_mock
        define_target_mock do |target_mock|
          target_mock.stubs(:user_can_deploy?).returns(false)
        end

        api_post "/api/deploy/target/test?repo_name=pardot"
        assert_json_error_response("locked")
      end

      it "should require a branch, tag or commit" do
        define_api_user_mock
        define_repo_mock
        define_target_mock do |target_mock|
          target_mock.stubs(:user_can_deploy?).returns(true)
        end

        api_post "/api/deploy/target/test?repo_name=pardot"
        assert_json_error_response("No branch")
      end

      it "should indicate unknown branch" do
        define_api_user_mock
        define_repo_mock
        define_target_mock do |target_mock|
          target_mock.stubs(:user_can_deploy?).returns(true)
        end
        Octokit.expects(:branches).returns([])

        api_post "/api/deploy/target/test?repo_name=pardot&branch=build1234"
        assert_json_error_response("Invalid branch")
      end

      it "should indicate unknown tag" do
        define_api_user_mock
        define_repo_mock
        define_target_mock do |target_mock|
          target_mock.stubs(:user_can_deploy?).returns(true)
        end
        Octokit.expects(:tags).returns([])

        api_post "/api/deploy/target/test?repo_name=pardot&tag=build1234"
        assert last_response.ok?
        assert !json_response["deployed"]
        assert_match "Invalid tag", json_response["message"]
      end

      it "should indicate deploy and give callback URL" do
        define_api_user_mock
        define_repo_mock
        define_target_mock do |target_mock|
          target_mock.stubs(:user_can_deploy?).returns(true)
          target_mock.expects(:deploy!).returns(Deploy.new(id: 1234))
        end
        Octokit.expects(:tags).returns([OpenStruct.new(name: 'build1234')])

        api_post "/api/deploy/target/test?repo_name=pardot&tag=build1234"
        assert last_response.ok?
        assert json_response["deployed"]
        assert_equal "/api/status/deploy/1234", json_response["status_callback"]
      end
    end
  end # /api/deploy/target

  # --------------------------------------------------------------------------
  describe "/api/status/deploy/:deploy_id" do
    describe "without authentication" do
      it "should error" do
        get "/api/status/deploy/1"
        assert_json_error_response("auth token")
      end

      it "should not respond to POST" do
        post "/api/status/deploy/1"
        assert last_response.not_found?
      end
    end

    describe "with authentication" do
      it "should require target" do
        assoc_mock = mock
        assoc_mock.expects(:first).returns(nil)
        Deploy.expects(:where).with(id: 1).returns(assoc_mock)

        api_get "/api/status/deploy/1"
        assert_json_error_response("Unable to find")
      end

      it "should give info on status of deploy" do
        deploy = Deploy.new(id: 1, what: "tag", what_details: "1234", completed: true)
        deploy.expects(:deploy_target).returns(OpenStruct.new(name: "test"))
        deploy.expects(:auth_user).returns(OpenStruct.new(email: "sveader@salesforce.com"))
        # deploy.expects(:repo).returns(OpenStruct.new(name: "pardot"))

        assoc_mock = mock
        assoc_mock.expects(:first).returns(deploy)
        Deploy.expects(:where).with(id: 1).returns(assoc_mock)

        api_get "/api/status/deploy/1"
        assert last_response.ok?
        assert json_response["completed"]
      end
    end
  end # /api/status/deploy

end
