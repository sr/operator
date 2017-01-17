require "rails_helper"

describe "Receiving GitHub hooks", :type => :request do
  def request_headers(event = "ping", remote_ip = "192.30.252.41")
    uuid = SecureRandom.uuid
    {
      "REMOTE_ADDR": remote_ip,
      "X_FORWARDED_FOR": remote_ip,
      "X-Github-Event": event,
      "X-Github-Delivery": uuid
    }
  end

  def signed_headers(payload, key = nil, headers = nil)
    headers ||= request_headers
    key ||= ENV["GITHUB_WEBHOOK_SECRET"]

    sha = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new("sha1"),
      key,
      payload
    )

    headers["X-Hub-Signature"] = "sha1=#{sha}"
    headers
  end

  describe "POST /webhooks" do
    describe "Hosts verification" do
      it "returns a forbidden error to invalid hosts" do
        post "/webhooks", params: fixture_data("github/ping"),
                          headers: request_headers("ping", "74.125.239.105")

        expect(response).to be_forbidden
        expect(response.status).to eql(403)
      end

      it "returns a unprocessable error for invalid events" do
        post "/webhooks", params: {},
                          headers: request_headers("invalid")

        expect(response.status).to eql(422)
      end

      it "handles ping events from valid hosts" do
        post "/webhooks", params: fixture_data("github/ping"),
                          headers: request_headers

        expect(response).to be_successful
        expect(response.status).to eql(201)
      end
    end

    describe "#verify_signature" do
      it "returns a forbidden error if the signature can't be verified" do
        payload = fixture_data("github/ping")
        headers = signed_headers(payload, "123", request_headers)

        post "/webhooks", params: payload,
                          headers: headers

        expect(response).to be_forbidden
        expect(response.status).to eql(403)
      end

      it "handles ping events with valid signatures" do
        payload = fixture_data("github/ping")
        headers = signed_headers(payload)

        post "/webhooks", params: payload,
                          headers: headers

        expect(response).to be_successful
        expect(response.status).to eql(201)
      end
    end

    describe "Pull Request events" do
      it "creates multipasses for public repository pull requests", :type => :webmock do
        expect do
          stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))
          Sidekiq::Testing.inline! do
            post "/webhooks", params: fixture_data("github/pull_request_opened_public"),
                              headers: request_headers("pull_request")

            expect(response).to be_successful
            expect(response.status).to eql(201)
          end
        end.to change { Multipass.count }
      end

      it "creates multipasses for pull request opened events", :type => :webmock do
        pull_data = decoded_fixture_data("github/pull_request_opened")
        repo = GithubInstallation.current.repositories.create!(
          github_id: pull_data["repository"]["id"],
          github_owner_id: pull_data.fetch("repository").fetch("owner").fetch("id"),
          name: pull_data["repository"]["name"],
          owner: pull_data["repository"]["owner"]["login"],
        )
        stub_request(:get, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")
          .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
        stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")
        stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))
        expect do
          Sidekiq::Testing.inline! do
            post "/webhooks", params: fixture_data("github/pull_request_opened"),
                              headers: request_headers("pull_request")

            expect(response).to be_successful
            expect(response.status).to eql(201)
          end
        end.to change { Multipass.count }.from(0).to 1
        multipass = Multipass.first
        expect(multipass.requester).to eql("corey@heroku.com")
        expect(multipass.team).to eql("Tools")
        expect(multipass.impact).to eql("low")
        expect(multipass.change_type).to eql("minor")
        expect(multipass.backout_plan).to eql("We revert the pull request.")
        expect(multipass.impact_probability).to eql("medium")
        expect(multipass.reference_url).to eql("https://github.com/heroku/changeling/pull/32")
        expect(multipass.audits.size).to eql(1)
        expect(multipass.repository_id).to eq(repo.id)
        expect(multipass.audits[0].comment)
          .to eql("API: Created from webhook https://github.com/heroku/changeling/pull/32")
      end

      it "updates multipass commit statuses for pull request synchronize events", :type => :webmock do
        stub_request(:get, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")
          .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
        stub_request(:get, "https://api.github.com/repos/heroku/changeling/statuses/c95e3c0492c0c0456c396389b97ea486fa32c9af")
          .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
        stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/c95e3c0492c0c0456c396389b97ea486fa32c9af")
        stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")
        stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))
        pull_request_open_webhook = decoded_fixture_data("github/pull_request_opened")
        multipass = Multipass.find_or_initialize_by_pull_request(pull_request_open_webhook)
        multipass.save
        after_sha  = "c95e3c0492c0c0456c396389b97ea486fa32c9af"
        before_sha = "ffa01fcbf02757d6cae5d928c2315adbaa2ec582"

        expect do
          expect do
            Sidekiq::Testing.inline! do
              post "/webhooks", params: fixture_data("github/pull_request_synchronize"),
                                headers: request_headers("pull_request")

              expect(response).to be_successful
              expect(response.status).to eql(201)
            end
          end.to change { multipass.reload.release_id }.from(before_sha).to(after_sha)
        end.to_not change { Multipass.count }
      end

      it "creates multipasses for pull request merged events" do
        stub_request(:get, "https://api.github.com/repos/heroku/heimdall/statuses/7f5f302843466a15802e935c0ca612731345bea2")
          .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
        stub_request(:post, "https://api.github.com/repos/heroku/heimdall/statuses/7f5f302843466a15802e935c0ca612731345bea2")
        stub_request(:get, "https://api.github.com/repos/heroku/heimdall/statuses/b17ca5ed8980cd7620f9a359053f988eee42953f")
          .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
        stub_request(:post, "https://api.github.com/repos/heroku/heimdall/statuses/b17ca5ed8980cd7620f9a359053f988eee42953f")
        stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))

        expect do
          Sidekiq::Testing.inline! do
            post "/webhooks", params: fixture_data("github/pull_request_opened_for_squash"),
                              headers: request_headers("pull_request")
            expect(response).to be_successful
            expect(response.status).to eql(201)

            mp = Multipass.last
            mp.peer_reviewer = "ys"
            mp.testing = true
            mp.save

            post "/webhooks", params: fixture_data("github/pull_request_merged_with_squash"),
                              headers: request_headers("pull_request")
            expect(response).to be_successful
            expect(response.status).to eql(201)
          end
        end.to change { Multipass.count }.by(1)
        expect(Multipass.last).to be_complete
      end

      it "doesn't create multipasses for pull request closed events" do
        expect do
          Sidekiq::Testing.inline! do
            post "/webhooks", params: fixture_data("github/pull_request_closed"),
                              headers: request_headers("pull_request")

            expect(response).to be_successful
            expect(response.status).to eql(201)
          end
        end.to_not change { Multipass.count }
      end
    end

    describe "Commit Status events" do
      it "sets testing to true for the corresponding multipass if commit status is successful" do
        ci_success = decoded_fixture_data("github/status_success_travis")
        # I want an incomplete multipass to avoid the callback
        Fabricate(:multipass, release_id:   ci_success["commit"]["sha"],
                              change_type:  "major",
                              sre_approver: nil,
                              testing:      false)
        expect do
          Sidekiq::Testing.inline! do
            post "/webhooks", params: fixture_data("github/status_success_travis"),
                              headers: request_headers("status")

            expect(response).to be_successful
            expect(response.status).to eql(201)
          end
        end.to change { Multipass.last.testing }.from(false).to(true)
      end

      it "leaves testing to false for the corresponding multipass if commit status is not success" do
        %w{pending failure}.each do |status|
          ci_msg = decoded_fixture_data("github/status_#{status}_travis")
          # I want an incomplete multipass to avoid the callback
          Fabricate(:multipass, release_id:   ci_msg["commit"]["sha"],
                                change_type:  "major",
                                sre_approver: nil,
                                testing:      false)
          expect do
            Sidekiq::Testing.inline! do
              post "/webhooks", params: fixture_data("github/status_#{status}_travis"),
                                headers: request_headers("status")

              expect(response).to be_successful
              expect(response.status).to eql(201)
            end
          end.to_not change { Multipass.last.testing }.from(false)
        end
      end

      it "leaves testing to false for the corresponding multipass if commit status is not from a valid context (Travis)" do
        ci_msg = decoded_fixture_data("github/status_pending_unknown")
        # I want an incomplete multipass to avoid the callback
        Fabricate(:multipass, release_id:   ci_msg["commit"]["sha"],
                              change_type:  "major",
                              sre_approver: nil,
                              testing:      false)
        expect do
          Sidekiq::Testing.inline! do
            post "/webhooks", params: fixture_data("github/status_pending_unknown"),
                              headers: request_headers("status")

            expect(response).to be_successful
            expect(response.status).to eql(201)
          end
        end.to_not change { Multipass.last.testing }.from(false)
      end
    end

    describe "Issue Comment events" do
      before do
        stub_request(:get, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")
          .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
        stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))

        pull_request_data = decoded_fixture_data("github/pull_request_opened")
        multipass = Multipass.find_or_initialize_by_pull_request(pull_request_data)
        multipass.testing = true
        multipass.change_type = "minor"
        multipass.save
      end

      it "approves if the input is :+1: and not creator of PR" do
        stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")

        user = User.new(github_login: "ys")
        user.github_token = SecureRandom.hex(24)
        user.save

        multipass = Multipass.last
        expect(multipass.audits.size).to eql(1)
        expect(multipass.audits[0].comment).to eql(nil)

        expect do
          Sidekiq::Testing.inline! do
            post "/webhooks", params: fixture_data("github/issue_comment_plus_one"),
                              headers: request_headers("issue_comment")

            expect(response).to be_successful
            expect(response.status).to eql(201)
          end
        end.to change { multipass.reload.status }.from("pending").to("complete")

        expect(multipass.audits.size).to eql(2)
        expect(multipass.audits[1].comment)
          .to eql("API: Updated from webhook ':+1:' - https://github.com/heroku/changeling/pull/32#issuecomment-193964950")
      end
    end

    describe "Pull Request Review events" do
      it "Approve if state is approved" do
        User.create!(github_login: "ys")
        Fabricate(:incomplete_multipass,
                  reference_url: "https://github.com/heroku/changeling-pr-tests/pull/85",
                  impact: "low",
                  impact_probability: "low",
                  change_type: "minor",
                  testing: true,
                  requester: "atmos")

        multipass = Multipass.last
        expect(multipass.audits.size).to eql(1)
        expect(multipass.audits[0].comment).to eql(nil)

        expect do
          Sidekiq::Testing.inline! do
            post "/webhooks", params: fixture_data("github/pull_request_review_approved"),
                              headers: request_headers("pull_request_review")

            expect(response).to be_successful
            expect(response.status).to eql(201)
          end
        end.to change { multipass.reload.status }.from("pending").to("complete")

        expect(multipass.audits.size).to eql(2)
        expect(multipass.audits[1].comment)
          .to eql("API: Updated from PullRequest Review webhook '' - https://github.com/heroku/changeling-pr-tests/pull/85#pullrequestreview-3917889")
      end
    end
  end

  describe "PushEvent" do
    include ActiveJob::TestHelper

    it "enqueues a job to synchronize OWNERS files on PushEvent for the master branch" do
      assert_enqueued_with(job: RepositoryOwnersFileSynchronizationJob, args: ["Pardot/chef"]) do
        post "/webhooks", params: fixture_data("github/push_event"),
          headers: request_headers("push")
        expect(response).to be_successful
        expect(response.status).to eql(201)
      end
    end
  end
end
