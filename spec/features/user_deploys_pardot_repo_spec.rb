require "rails_helper"

RSpec.feature "user deploys pardot repo" do
  before do
    Rails.application.config.deployment.strategy.clear

    DeployTarget.create! \
      name: "test",
      script_path: "/tmp/sync_scripts",
      lock_path: "/tmp/sync_scripts/lock",
      locked: false

    allow(Octokit).to receive(:tags).with("Pardot/pardot", per_page: 30)
      .and_return([
        OpenStruct.new(name: "build1234"),
      ])

    allow(Octokit).to receive(:ref).with("Pardot/pardot", "tags/build1234")
      .and_return(OpenStruct.new(object: OpenStruct.new(sha: "abc123")))
    allow(Octokit).to receive(:tag).with("Pardot/pardot", "abc123")
      .and_return(OpenStruct.new(
        tag: "build1234",
        object: OpenStruct.new(sha: "abc123"),
        tagger: OpenStruct.new(date: Time.now)))
  end

  scenario "happy path deployment" do
    login_as "Joe Syncmaster", "joe.syncmaster@salesforce.com"

    find(".repos a", text: "Pardot").click
    find(".deploy-targets a", text: "Latest Tag").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship it Here").click
    click_button "SHIP IT!"
    expect(page).to have_text("Watching deploy of Pardot")

    test_deploy_strategy = Rails.application.config.deployment.strategy
    expect(test_deploy_strategy.deploys.length).to eq(1)
    expect(test_deploy_strategy.deploys[0].auth_user.email).to eq("joe.syncmaster@salesforce.com")
    expect(test_deploy_strategy.deploys[0].repo_name).to eq("pardot")
    expect(test_deploy_strategy.deploys[0].what).to eq("tag")
    expect(test_deploy_strategy.deploys[0].what_details).to eq("build1234")
    expect(test_deploy_strategy.deploys[0].server_count).to eq(1)
    expect(test_deploy_strategy.deploys[0].servers_used).to eq("localhost")
    expect(test_deploy_strategy.deploys[0].specified_servers).to eq(nil)
    expect(test_deploy_strategy.deploys[0].sha).to eq("abc123")
  end
end
