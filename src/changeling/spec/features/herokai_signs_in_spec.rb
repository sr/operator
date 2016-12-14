require "rails_helper"

RSpec.describe "User signs in", :type => :feature do
  before(:all) do
    Changeling.config.require_heroku_organization_membership = true
  end

  it "is from Heroku organization" do
    body = [{ login: "heroku" }].to_json
    stub_json_request(:get, "#{Changeling.config.github_api_endpoint}/user/orgs", body)
    visit "/auth/github"
    expect(page).to have_content("joe")
  end

  it "is not from Heroku organization" do
    body = [{ login: "not-heroku" }].to_json
    stub_json_request(:get, "#{Changeling.config.github_api_endpoint}/user/orgs", body)
    visit "/auth/github"
    expect(page).to_not have_content("joe")
    expect(page).to have_content("Sorry")
  end
end
