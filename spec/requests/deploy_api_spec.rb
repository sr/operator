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
end
