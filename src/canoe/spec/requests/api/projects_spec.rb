require "rails_helper"

RSpec.describe "/api/projects" do
  it "returns list of projects" do
    FactoryGirl.create(:project, name: "boomtown")
    api_get "/api/projects"
    expect(json_response.size).to eq(1)
    expect(json_response[0]["name"]).to eq("boomtown")
  end
end
