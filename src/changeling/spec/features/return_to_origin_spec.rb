require "rails_helper"

RSpec.describe "User sign in keeps origin", :type => :feature do
  it "is redirected to current page after login" do
    body = [{ login: "heroku" }].to_json
    stub_json_request(:get, "https://api.github.com/user/orgs", body)
    multipass = Fabricate(:multipass)
    visit multipass_path(multipass)
    expect(current_path).to eq(multipass_path(multipass))
  end
end
