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
end
