require "rails_helper"

RSpec.describe "Filters complete" do
  before do
    auth_as_herokai("ys")
    ys = User.last
    ys.team = "tools"
    ys.save
    coal_car_url = "https://github.com/heroku/coal_car/pull/32"
    direwolf_url = "https://github.com/heroku/direwolf/pull/33"
    Fabricate(:complete_multipass,
              team: "tools",
              reference_url: coal_car_url)
    Fabricate(:incomplete_multipass,
              requester: "ys",
              team: "tools",
              reference_url: direwolf_url)
  end

  it "shows all the multipasses when complete is blank" do
    get "/?complete="
    expect(response.body).to include "heroku/coal_car"
    expect(response.body).to include "PR#32"
    expect(response.body).to include "heroku/direwolf"
    expect(response.body).to include "PR#33"
  end

  it "shows only the complete multipasses when complete is true" do
    get "/?complete=true"
    expect(response.body).to include "heroku/coal_car"
    expect(response.body).to include "PR#32"
    expect(response.body).to_not include "heroku/direwolf"
    expect(response.body).to_not include "PR#33"
  end

  it "shows only the incomplete multipasses when complete is false" do
    get "/?complete=false"
    expect(response.body).to_not include "heroku/coal_car"
    expect(response.body).to_not include "PR#32"
    expect(response.body).to include "heroku/direwolf"
    expect(response.body).to include "PR#33"
  end
end
