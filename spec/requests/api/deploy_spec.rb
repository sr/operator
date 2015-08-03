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
end
