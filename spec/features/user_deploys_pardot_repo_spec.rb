require "rails_helper"

RSpec.feature "user deploys pardot repo" do
  before do
    FactoryGirl.create(:deploy_target, name: "test")
    @repo = FactoryGirl.create(:repo, name: "pardot")

    allow(Octokit).to receive(:tags).with("Pardot/#{@repo.name}", per_page: 30)
      .and_return([
        OpenStruct.new(name: "build1234"),
      ])

    allow(Octokit).to receive(:ref).with("Pardot/#{@repo.name}", "tags/build1234")
      .and_return(OpenStruct.new(object: OpenStruct.new(sha: "abc123")))
    allow(Octokit).to receive(:tag).with("Pardot/#{@repo.name}", "abc123")
      .and_return(OpenStruct.new(
        tag: "build1234",
        object: OpenStruct.new(sha: "abc123"),
        tagger: OpenStruct.new(date: Time.now)))
  end

  scenario "happy path deployment" do
    login_as "Joe Syncmaster", "joe.syncmaster@salesforce.com"

    find(".repos a", text: @repo.name.capitalize).click
    find(".deploy-targets a", text: "latest tag").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship it Here").click
    click_button "SHIP IT!"
    expect(page).to have_text("Watching deploy of #{@repo.name.capitalize}")

    test_deploy_strategy = Rails.application.config.deployment.strategy
    expect(test_deploy_strategy.deploys.length).to eq(1)
    expect(test_deploy_strategy.deploys[0].auth_user.email).to eq("joe.syncmaster@salesforce.com")
    expect(test_deploy_strategy.deploys[0].repo_name).to eq(@repo.name)
    expect(test_deploy_strategy.deploys[0].what).to eq("tag")
    expect(test_deploy_strategy.deploys[0].what_details).to eq("build1234")
    expect(test_deploy_strategy.deploys[0].server_count).to eq(1)
    expect(test_deploy_strategy.deploys[0].servers_used).to eq("localhost")
    expect(test_deploy_strategy.deploys[0].specified_servers).to eq(nil)
    expect(test_deploy_strategy.deploys[0].sha).to eq("abc123")
  end
end
