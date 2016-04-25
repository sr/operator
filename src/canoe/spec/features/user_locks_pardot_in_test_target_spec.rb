require "rails_helper"

RSpec.feature "user locks pardot in test target" do
  before do
    @target = FactoryGirl.create(:deploy_target, name: "test")
    @repo = FactoryGirl.create(:repo, name: "pardot")
  end

  scenario "happy path locking" do
    expect(@target.existing_lock(@repo)).not_to be

    login_as "Joe Syncmaster", "joe.syncmaster@salesforce.com"

    find(".targets a", text: @target.name.capitalize).click
    find("table.repos tr[data-repo='#{@repo.name}'] a", text: "Lock").click

    expect(page).to have_text("Lock acquired")

    lock = @target.existing_lock(@repo)
    expect(lock).to be
    expect(lock.auth_user.email).to eq("joe.syncmaster@salesforce.com")
  end
end
