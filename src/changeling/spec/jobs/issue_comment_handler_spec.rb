require "rails_helper"

describe IssueCommentHandler do
  before do
    stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))

    pull_request_data = decoded_fixture_data("github/pull_request_opened")

    sha = pull_request_data["pull_request"]["head"]["sha"]

    url = "https://api.github.com/repos/heroku/changeling/statuses/#{sha}"
    stub_request(:get, url)
      .to_return(body: "[]", headers: { "Content-type" => "application/json" })
    multipass = Multipass.find_or_initialize_by_pull_request(pull_request_data)
    multipass.testing = true
    multipass.change_type = "minor"
    multipass.save

    user = User.new(github_login: "ys")
    user.github_token = SecureRandom.hex(24)
    user.save
  end

  ["👍", "👍🏿", "+1", "lgtm", "LGTM", "Looks good to me", ":+1:", ":shipit:", "Legit :+1:\r\n"].each do |issue_comment|
    it "approves if the input is '#{issue_comment}' and not creator of PR" do
      plus_one_fixture = decoded_fixture_data("github/issue_comment_plus_one")
      plus_one_fixture["comment"]["body"] = issue_comment
      expect do
        IssueCommentHandler.perform_now(nil, JSON.dump(plus_one_fixture))
      end.to change { Multipass.first.status }.from("pending").to("complete")
    end

    it "does not approves if the input is #{issue_comment} and creator of PR" do
      %w{ignore not_found plus_one_owner_denied plus_one_user_not_found}.each do |name|
        plus_one_fixture = decoded_fixture_data("github/issue_comment_#{name}")
        plus_one_fixture["comment"]["body"] = issue_comment
        expect do
          IssueCommentHandler.perform_now(nil, JSON.dump(plus_one_fixture))
        end.to_not change { Multipass.first.status }
      end
    end
  end
end
