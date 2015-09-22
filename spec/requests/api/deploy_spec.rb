require "rails_helper"

RSpec.describe "/api/deploy" do
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

      context "sync_script servers" do
        it "should add to existing list of servers" do
          define_deploy_mock(3) do |deploy_mock|
            allow(deploy_mock).to receive(:completed_servers).and_return("foo,bar")
            expect(deploy_mock).to receive(:update_attribute).with(:completed_servers, "foo,bar,test-server")
          end

          api_post "/api/deploy/3/completed_server", { server: "test-server" }
          assert_nonerror_response
        end
      end

      context "pull_agent servers" do
        it "updates the deploy result record for the server" do
          server = FactoryGirl.create(:server)
          deploy = FactoryGirl.create(:deploy)
          result = deploy.results.create!(server: server)

          api_post "/api/deploy/#{deploy.id}/completed_server", { server: server.hostname }
          assert_nonerror_response

          result.reload
          expect(result.status).to eq("completed")
        end
      end
    end
  end
end
