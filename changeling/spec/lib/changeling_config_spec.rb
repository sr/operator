require "rails_helper"

RSpec.describe ChangelingConfig do
  it "has sane defaults running in default mode" do
    user   = Fabricate :user, github_login: "atmos"
    config = ChangelingConfig.new
    config.pardot = false

    expect(config).to_not be_pardot
    expect(config.require_heroku_organization_membership?).to be_truthy
    expect(config.review_approval_enabled_for?(user)).to be_truthy
    expect(config).to be_approval_via_comment_enabled
    expect(config.compliance_status_context).to eql("heroku/compliance")
    expect(config.default_repo_name).to eql("heroku/unknown-app")
    expect(config.rollbar_enabled?).to be_falsey
    expect(config.github_hostname).to eql("github.com")
    expect(config.github_api_endpoint).to eql("https://api.github.com")
    expect(config.github_source_ips).to eql(["192.30.252.0/22"])
  end

  it "behaves differently in pardot mode" do
    config = ChangelingConfig.new
    config.pardot = true

    ENV["GITHUB_HOSTNAME"] = "ghe.pardot.salesforce.com"
    ENV["GITHUB_WEBHOOK_SOURCE_IP"] = "172.16.252.0/22"

    expect(config).to be_pardot
    expect(config.require_heroku_organization_membership?).to_not be_truthy
    expect(config.review_approval_enabled_for?(nil)).to be_truthy
    expect(config).to_not be_approval_via_comment_enabled
    expect(config.default_repo_name).to eql("Pardot/unknown")
    expect(config.rollbar_enabled?).to be_falsey
    expect(config.github_hostname).to eql("ghe.pardot.salesforce.com")
    expect(config.github_api_endpoint).to eql("https://ghe.pardot.salesforce.com/api/v3")
    expect(config.github_source_ips).to eql(["172.16.252.0/22"])

    ENV.delete("GITHUB_HOSTNAME")
    ENV.delete("GITHUB_WEBHOOK_SOURCE_IP")
  end
end
