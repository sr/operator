module ChatNotificationHelpers
  def new_release_create_event
    payload = JSON.parse(fixture_data("tonitrus/release_create_heroku_app"))
    event = Event.new_from_payload(payload)
    multipass = Fabricate(:multipass)
    multipass.release_id = event.release_sha
    multipass.save
    event.multipass = multipass
    return unless event.valid? && multipass.valid?
    event
  end

  def default_headers_for_chat_notifying
    {
      "Accept"          => "*/*",
      "Content-Type"    => "application/json",
      "User-Agent"      => "Faraday v0.9.2",
      "Authorization"   => "Bearer fake-heimdall-api-token",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
    }
  end

  def stub_chat(repo_bearer)
    stub_chat_for_repo(repo_bearer.repository)
  end

  def stub_chat_for_repo(repo)
    url = chat_url_from_repo(repo)

    stub_request(:post, url)
      .with(headers: default_headers_for_chat_notifying)
      .to_return(status: 200, body: "")
  end

  def stub_heimdall_apps
    stub_request(:get, heimdall_apps_url).to_return(body: "{}", status: 200)
  end

  def chat_url_from_repo(repo)
    "#{ChatNotificationHelpers.heimdall_url}/hubot-deploy" \
      "/repos/#{repo.name_with_owner}/messages"
  end

  def heimdall_apps_url
    "#{ChatNotificationHelpers.heimdall_url}/hubot-deploy/apps"
  end

  def self.heimdall_url
    ENV["HEIMDALL_API_URL"]
  end
end
