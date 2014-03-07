require File.join(File.dirname(__FILE__), "test_helper.rb")

describe Deploy do
  include Rack::Test::Methods

  def app
    CanoeApplication
  end

  describe "accessing /deploy/target/:target_name" do
    describe "without authentication" do
      it "GET: should redirect to login" do
        get "/deploy/target/foo"
        assert_redirect_to_login
      end

      it "POST: should redirect to login" do
        post "/deploy/target/foo"
        assert_redirect_to_login
      end
    end

    describe "with authentication" do
      it "GET: should 404" do
        define_target_mock
        get_request_with_auth "/deploy/target/test"
        assert last_response.not_found?
      end

      describe "with POST" do
        it "should require repo passed" do
          define_target_mock
          post_request_with_auth "/deploy/target/test"
          # TODO: how do we check for the flash message?
          assert last_response.redirect?
        end

        it "should require target passed" do
          define_repo_mock
          define_target_missing_mock("foo")
          post_request_with_auth "/deploy/target/foo?repo_name=pardot"
          # TODO: how do we check for the flash message?
          assert last_response.redirect?
        end

        it "should redirect if user is unable to deploy" do
          define_repo_mock
          define_target_mock do |target_mock|
            target_mock.stubs(:user_can_deploy?).returns(false)
          end

          post_request_with_auth "/deploy/target/test?repo_name=pardot"
          assert last_response.redirect?
        end

        it "should deploy if everything is passed" do
          define_repo_mock
          define_target_mock do |target_mock|
            target_mock.expects(:user_can_deploy?).returns(true)

            deploy_mock = mock(id: 1234)
            target_mock.expects(:deploy!).returns(deploy_mock)
          end

          post_request_with_auth "/deploy/target/test?repo_name=pardot&tag=5678"
          assert last_response.redirect?
          assert_match "/deploy/1234/watch", last_response.location
        end
      end
    end

  end

end
