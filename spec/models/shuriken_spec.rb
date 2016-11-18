require "rails_helper"

RSpec.describe Shuriken do
  it "posts a multipass to shuriken" do
    multipass = Fabricate(:multipass)

    body = {
      type: "type",
      multipass: anything
    }
    request = stub_json_request(:post, "https://changeling:123@shuriken.heroku.tools/webhooks/changeling", "{}").with(body: body)

    Shuriken.new.publish("type", multipass)
    expect(request).to have_been_requested
  end
end
