require "rails_helper"

RSpec.describe EmergencyOverrideMailer, type: [:mailer] do
  before do
    Changeling.config.email_notifications_enabled = true

    stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))

    pull_request_data = decoded_fixture_data("github/pull_request_opened")

    sha = pull_request_data["pull_request"]["head"]["sha"]

    url = "https://api.github.com/repos/heroku/changeling/statuses/#{sha}"
    stub_request(:get, url)
      .to_return(body: "[]", headers: { "Content-type" => "application/json" })
    @multipass = Multipass.find_or_initialize_by_pull_request(pull_request_data)
    @multipass.testing = true
    @multipass.change_type = ChangeCategorization::STANDARD
    @multipass.emergency_approver = Faker::Internet.user_name
    @multipass.save

    user = User.new(github_login: "ys")
    user.github_token = SecureRandom.hex(24)
    user.save
  end

  it "generates an email" do
    EmergencyOverrideMailer.send_multipass(@multipass).deliver
    mails = ActionMailer::Base.deliveries
    expect(mails).to_not be_empty
    mail = mails.first
    expect(mail.to).to eql(["tools+hipaa+notifications@heroku.com"])
    expect(mail.from).to eql(["tools+noreply@heroku.com"])
    expect(mail.subject).to eql(
      "Changeling Emergency Override heroku/changeling"
    )

    body = mail.body.to_s
    expect(body).to include(@multipass.permalink)
    expect(body).to include(@multipass.emergency_approver)
  end
end
