require "rails_helper"

describe "emergency override" do
  include AuthenticationHelpers
  include FormHelpers
  include CapybaraHelpers

  let(:multipass) { Fabricate(:multipass) }

  before do
    WebMock.disable_net_connect!
    stub_chat(multipass)
  end

  it "sets the emergency approver to the current user" do
    user = login_with_oauth
    visit multipass_path(multipass.id)

    expect do
      submit_emergency
    end.to change { multipass.reload.emergency_approver }.to user
  end

  it "sends a notification to chat about the emergency override" do
    login_with_oauth
    visit multipass_path(multipass.id)

    submit_emergency
  end
end
