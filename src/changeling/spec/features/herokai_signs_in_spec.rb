require "rails_helper"

RSpec.describe "User signs in", :type => :feature do
  it "is from Heroku organization" do
    body = [{ login: "heroku" }].to_json
    stub_json_request(:get, "https://api.github.com/user/orgs", body)
    visit "/auth/github"
    expect(page).to have_content("joe")
  end

  it "is not from Heroku organization" do
    body = [{ login: "not-heroku" }].to_json
    stub_json_request(:get, "https://api.github.com/user/orgs", body)
    visit "/auth/github"
    expect(page).to_not have_content("joe")
    expect(page).to have_content("Sorry")
  end
end
