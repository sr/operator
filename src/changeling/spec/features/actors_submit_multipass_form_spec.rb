require "rails_helper"

describe "approver reviews a multipass" do
  include AuthenticationHelpers
  include FormHelpers
  include CapybaraHelpers

  let(:multipass) { Fabricate(:multipass) }

  before(:each) do
    SREApprover.all = [
      SREApprover.new(github_uid: 234, github_login: "joe"),
      SREApprover.new(github_uid: 123, github_login: "ys")
    ]
  end

  after do
    SREApprover.all = nil
  end

  actor = "peer_reviewer"
  actor_form = "multipass_peer_reviewer_form"

  it "sets the #{actor}" do
    multipass.update_attributes(actor => nil)

    login_with_oauth
    visit multipass_path(multipass.id)
    submit_form(actor_form)

    expect(multipass.reload.send(actor)).to_not be nil
  end

  it "does not change the #{actor} if it's already set" do
    multipass = Fabricate(:complete_multipass, actor => "ys")
    login_with_oauth

    visit multipass_path(multipass.id)
    expect { submit_form(actor_form) }.to_not change { multipass.reload.send(actor) }
  end

  it "does not change the #{actor} if the current_user is the requester" do
    user = login_with_oauth
    multipass.update_attributes(:requester => user, actor => nil)

    visit multipass_path(multipass.id)

    expect { submit_form(actor_form) }.to_not change { multipass.reload.send(actor) }
  end

  it "does not unset the #{actor} if the current_user is not the original #{actor}" do
    multipass = Fabricate(:complete_multipass, sre_approver: "ys")
    login_with_oauth

    visit multipass_path(multipass.id)

    submit_form(actor_form)
    visit multipass_path(multipass.id)
    expect { submit_form(actor_form) }.to_not change { multipass.reload.send(actor) }
  end

  it "unsets the #{actor} if the current_user set it originally" do
    user = login_with_oauth
    multipass.update_attributes(actor => user)

    visit multipass_path(multipass.id)

    submit_form(actor_form)
    expect(multipass.reload.send(actor)).to eql nil
  end
end
