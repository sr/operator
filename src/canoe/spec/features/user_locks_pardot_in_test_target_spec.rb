require "rails_helper"

RSpec.feature "user locks pardot in test target" do
  before do
    @target = FactoryGirl.create(:deploy_target, name: "test")
    @project = FactoryGirl.create(:project, name: "pardot")
  end

  scenario "happy path locking" do
    expect(@target.existing_lock(@project)).not_to be

    login_as "Joe Syncmaster", "joe.syncmaster@salesforce.com"

    find(".targets a", text: @target.name.capitalize).click
    find("table.projects tr[data-project='#{@project.name}'] a", text: "Lock").click

    expect(page).to have_text("Lock acquired")

    lock = @target.existing_lock(@project)
    expect(lock).to be
    expect(lock.auth_user.email).to eq("joe.syncmaster@salesforce.com")
  end
end
