require "rails_helper"

describe "Receiving Events hooks", :type => :request do
  describe "POST /events" do
    describe "authentication" do
      let(:external_id) { SecureRandom.uuid }
      let(:sha) { SecureRandom.hex(7) }
      let(:body) do
        {
          id: external_id,
          app_name: "limerick-test-app",
          sha: sha,
          user_email: "yannick@heroku.com"
        }.to_json
      end

      it "returns a forbidden for invalid token" do
        post "/events", headers: { "HTTP_AUTHORIZATION" => "Token wrong_token" }
        expect(response).to be_forbidden
        expect(response.status).to eql(403)
      end

      it "returns a 200 for valid token" do
        valid_auth = "Token #{ENV['WEBHOOK_API_TOKEN']}"
        post "/events", headers: { "HTTP_AUTHORIZATION" => valid_auth }
        expect(response.status).to eql(202)
      end

      it "creates an event", :type => :job do
        valid_auth = "Token #{ENV['WEBHOOK_API_TOKEN']}"
        multipass = Fabricate(:multipass, release_id: sha)
        stub_chat(multipass)
        user = User.create(github_login: "ys")

        expect do
          Sidekiq::Testing.inline! do
            post "/events", params: body, headers: { "HTTP_AUTHORIZATION" => valid_auth }
          end
        end.to change { Event.count }.by(1)

        event = Event.last
        expect(event.app_name).to eql "limerick-test-app"
        expect(event.external_id).to eql external_id
        expect(event.release_sha).to eql sha
        expect(event.multipass).to eql multipass
        expect(event.user).to eql user
      end
    end
  end
end
