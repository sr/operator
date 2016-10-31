require "rails_helper"

RSpec.describe DeployTarget do
  it "authorizes deploy" do
    user = FactoryGirl.create(:user)
    project = FactoryGirl.create(:project)
    target = FactoryGirl.create(:deploy_target)

    expect(user.deploy_authorized?(project, target)).to eq(true)

    DeployACLEntry.create!(
      project: project,
      deploy_target: target,
      acl_type: "ldap_group",
      value: "ohana"
    )

    expect_any_instance_of(DeployACLEntry).to receive(:ldap_group_authorized?).with(user).and_return(false)
    expect(user.deploy_authorized?(project, target)).to eq(false)
  end

  it "authenticates using paired phone" do
    user = FactoryGirl.create(:user)

    expect(user.authenticate_phone).to eq(false)
    expect(user.phone.paired?).to eq(false)

    user.phone.create_pairing("boom town")
    user.reload
    expect(user.phone.paired?).to eq(true)

    Canoe.salesforce_authenticator.authentication_status = { granted: false }
    expect(user.authenticate_phone(1, 0)).to eq(false)
    Canoe.salesforce_authenticator.authentication_status = { granted: true }
    expect(user.authenticate_phone(1, 0)).to eq(true)
  end
end
