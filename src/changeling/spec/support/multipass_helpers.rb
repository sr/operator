module MultipassHelpers
  def create_changeling_multipass_from_pr(body)
    pull_request_data = decoded_fixture_data("github/pull_request_opened")

    sha = pull_request_data["pull_request"]["head"]["sha"]

    stub_changeling_multipass_status(sha, body)

    multipass = Multipass.find_or_initialize_by_pull_request(pull_request_data)
    multipass.testing = false
    multipass.change_type = ChangeCategorization::STANDARD
    multipass.created_at = 10.minutes.ago
    multipass.peer_reviewer = "ys"
    multipass.save

    user = User.new(github_login: "ys")
    user.github_token = SecureRandom.hex(24)
    user.save
  end

  def stub_changeling_multipass_status(sha, body = "[]")
    stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))
    url = "https://api.github.com/repos/heroku/changeling/statuses/#{sha}"
    stub_request(:get, url)
      .to_return(body: body, headers: { "Content-type" => "application/json" })
  end
end
