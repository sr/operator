require File.join(File.dirname(__FILE__), "test_helper.rb")

describe Deploy do
  include Rack::Test::Methods

  def app
    CanoeApplication
  end

  describe "accessing /deploy/repo/:repo_name/to/target/:target_name" do
    describe "without authentication" do
      it "GET: should redirect to login" do
        get "/deploy/repo/foo/target/bar"
        assert_redirect_to_login
      end

      it "POST: should redirect to login" do
        get "/deploy/repo/foo/target/bar"
        assert_redirect_to_login
      end
    end

    describe "with authentication" do
      it "GET: should 404" do
        define_target_mock
        get_request_with_auth "/deploy/repo/pardot/to/target/test"
        assert last_response.not_found?
      end

      describe "with POST" do
        it "should require repo passed" do
          define_target_mock
          post_request_with_auth "/deploy/repo/foo/to/target/test"
           # TODO: how do we check for the flash message?
          assert last_response.redirect?
        end

        it "should require target passed" do
          define_target_missing_mock("foo")
          post_request_with_auth "/deploy/repo/pardot/to/target/foo"
          # TODO: how do we check for the flash message?
          assert last_response.redirect?
        end

        it "should redirect if user is unable to deploy" do
          define_repo_mock
          define_target_mock do |target_mock|
            target_mock.stubs(:user_can_deploy?).returns(false)
          end

          post_request_with_auth "/deploy/repo/pardot/to/target/test"
          assert last_response.redirect?
        end

        it "should check for existance of branch" do
          define_repo_mock
          define_target_mock do |target_mock|
            target_mock.expects(:user_can_deploy?).returns(true)
          end
          Octokit.expects(:ref).with("pardot/pardot", "heads/foo").returns({object:{}})

          post_request_with_auth "/deploy/repo/pardot/to/target/test?branch=foo"
          assert last_response.redirect?
        end

        it "should check for existance of tag" do
          define_repo_mock
          define_target_mock do |target_mock|
            target_mock.expects(:user_can_deploy?).returns(true)
          end
          Octokit.expects(:ref).with("pardot/pardot", "tags/foo").returns({object:{}})

          post_request_with_auth "/deploy/repo/pardot/to/target/test?tag=foo"
          assert last_response.redirect?
        end

        it "should check for existance of commit" do
          define_repo_mock
          define_target_mock do |target_mock|
            target_mock.expects(:user_can_deploy?).returns(true)
          end
          Octokit.expects(:commit).with("pardot/pardot", "foo").returns({})

          post_request_with_auth "/deploy/repo/pardot/to/target/test?commit=foo"
          assert last_response.redirect?
        end

        it "should deploy if everything is passed" do
          define_repo_mock
          define_target_mock do |target_mock|
            target_mock.expects(:user_can_deploy?).returns(true)

            deploy_mock = mock(id: 1234)
            target_mock.expects(:deploy!).returns(deploy_mock)
          end
          Octokit.expects(:ref).with("pardot/pardot", "tags/build5678").returns({object:{sha:"123455"}})

          post_request_with_auth "/deploy/repo/pardot/to/target/test?tag=build5678"
          assert last_response.redirect?
          assert_match "/deploy/1234/watch", last_response.location
        end
      end
    end

  end

end
