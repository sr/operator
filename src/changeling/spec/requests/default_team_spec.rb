require "rails_helper"

RSpec.describe "Filters to default team" do
  before do
    auth_as_herokai("ys")
    ys = User.last
    ys.team = "tools"
    ys.save
    changeling_url = "https://github.com/heroku/changeling/pull/32"
    not_changeling_url = "https://github.com/heroku/direwolf/pull/2"
    Fabricate(:multipass,
              team: "tools",
              reference_url: changeling_url)
    Fabricate(:multipass,
              team: "not_tools",
              reference_url: not_changeling_url)
  end

  it "only shows the multipasses for your team" do
    get "/"
    expect(response.body).to include "heroku/changeling"
    expect(response.body).to include "PR#32"
    expect(response.body).to_not include "heroku/direwolf"
    expect(response.body).to_not include "PR#2"
  end

  it "shows all the multipasses when by_team is blank" do
    get "/?by_team="
    expect(response.body).to include "heroku/changeling"
    expect(response.body).to include "PR#32"
    expect(response.body).to include "heroku/direwolf"
    expect(response.body).to include "PR#2"
  end
end
