require "rails_helper"

RSpec.describe "/health" do
  it "returns a 200" do
    get "/health"
    expect(status).to eql 200
    data = JSON.parse(body)
    expect(data["name"]).to eql("changeling")
    expect(data["database"]["healthy"]).to be true
    expect(data["redis"]["healthy"]).to be true
  end
end
