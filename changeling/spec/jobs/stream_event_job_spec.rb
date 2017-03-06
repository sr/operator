require "rails_helper"

RSpec.describe StreamEventJob, :type => :job do
  let(:event) { JSON.parse(fixture_data("tonitrus/release_create_heroku_app")) }

  it "creates Event" do
    stub_heimdall_apps
    stub_chat(Event.new_from_payload(event))

    expect do
      StreamEventJob.perform_now(event)
    end.to change { Event.count }.by(1)
  end
end
