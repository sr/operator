require "rails_helper"

describe ComplianceStatus, "pardot" do
  before(:each) do
    Changeling.config.pardot = true
    ticket = Ticket.create!(
      external_id: "1",
      summary: "fix everything",
      management_software: Ticket::TYPE_JIRA
    )
    reference_url = format("https://%s/%s/pull/90",
      Changeling.config.github_hostname,
      PardotRepository::CHANGELING
    )
    @multipass = Fabricate(:multipass, testing: true, reference_url: reference_url)
    @multipass.create_ticket_reference!(ticket: ticket)
    @user = Fabricate(:user)
  end

  it "can never be approved by a SRE" do
    @multipass.sre_approver = @user
    expect(@multipass.sre_approved?).to eq(false)
    expect(@multipass.user_is_sre_approver?(@user)).to eq(false)
  end

  it "requires a ticket reference to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.ticket_reference.destroy!
    expect(@multipass.reload.complete?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Ticket reference missing")
  end

  it "requires the builds to be successful" do
    expect(@multipass.complete?).to eq(true)
    @multipass.update!(testing: false)
    expect(@multipass.reload.complete?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Build failed")
  end

  it "requires the build to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.update!(testing: nil)
    expect(@multipass.reload.complete?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Build pending")
  end
end
