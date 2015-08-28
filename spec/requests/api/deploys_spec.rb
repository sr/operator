require "rails_helper"

RSpec.describe "/api/targets/:target_name/deploys" do
  describe "/api/targets/:target_name/deploys/latest" do
    describe "without authentication" do
      it "should error" do
        post "/api/targets/dev/deploys/latest"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      describe "without repo_name" do
        it "should error" do
          api_post "/api/targets/dev/deploys/latest", { }
          assert_json_error_response("Invalid repo")
        end
      end

      describe "with a bogus repo name" do
        it "should error" do
          api_post "/api/targets/dev/deploys/latest", { repo_name: "foobar" }
          assert_json_error_response("Invalid repo")
        end
      end

      describe "with a good repo name" do
        it "should list the latest deploy info" do
          deploy = Deploy.new(id: 1, what: "tag", what_details: "1234", completed: true)
          expect(deploy).to receive(:deploy_target).and_return(OpenStruct.new(name: "test"))
          expect(deploy).to receive(:auth_user).and_return(OpenStruct.new(email: "sveader@salesforce.com"))
        # expect(deploy).to receive(:repo).and_return(OpenStruct.new(name: "pardot"))
          define_target_mock do |target_mock|
            expect(target_mock).to receive(:last_deploy_for).and_return(deploy)
          end
          api_post "/api/targets/test/deploys/latest", { repo_name: "pardot" }
          assert_nonerror_response
        end
      end
    end
  end
end