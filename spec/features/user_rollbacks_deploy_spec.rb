require "rails_helper"

RSpec.feature "user rollbacks deploy" do
  before do
    @deploy_target = FactoryGirl.create(:deploy_target, name: "test")
    @repo = FactoryGirl.create(:repo, name: "pardot", deploys_via_artifacts: true)
    @server = FactoryGirl.create(:server, hostname: "app-s1.example")
    @server.deploy_scenarios.create!(deploy_target: @deploy_target, repo: @repo)

    allow(Octokit).to receive(:branch)
      .with("Pardot/#{@repo.name}", "master")
      .and_return(OpenStruct.new(name: "master", object: OpenStruct.new(sha: "bcd234")))

    allow(Octokit).to receive(:compare)
      .and_return(nil)

    allow(Artifactory.client).to receive(:post)
      .and_return("results" => [
        {"repo" => "pd-canoe", "path" => "PDT/PPANT", "name" => "build1234.tar.gz"},
      ])

    allow(Artifactory.client).to receive(:get)
      .with(%r{pd-canoe/PDT/PPANT/build1234.tar.gz}, properties: nil)
      .and_return(
        "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
        "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
        "properties" => {
          "gitBranch"      => ["master"],
          "buildNumber"    => ["1234"],
          "gitSha"         => ["bcd234"],
          "buildTimeStamp" => ["2015-09-11T18:51:37.047-04:00"],
        },
      )
  end

  scenario "happy path rollback" do
    # create existing deploy that will be used as the rollback target
    first_deploy = FactoryGirl.create(:deploy,
      repo_name: @repo.name,
      deploy_target: @deploy_target,
      completed: true,
      canceled: false,
      sha: "abc123",
    )

    login_as "Joe Syncmaster", "joe.syncmaster@salesforce.com"

    find(".repos a", text: @repo.name.capitalize).click
    find(".deploy-targets a", text: "master").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship it Here").click
    click_button "SHIP IT!"
    expect(page).to have_text("Watching deploy of #{@repo.name.capitalize}")

    click_button "CANCEL & ROLLBACK"

    test_deploy_strategy = Rails.application.config.deployment.strategy
    expect(test_deploy_strategy.deploys.length).to eq(2)

    latest_deploy = test_deploy_strategy.deploys.last
    expect(latest_deploy.auth_user.email).to eq("joe.syncmaster@salesforce.com")
    expect(latest_deploy.repo_name).to eq(first_deploy.repo_name)
    expect(latest_deploy.what).to eq(first_deploy.what)
    expect(latest_deploy.what_details).to eq(first_deploy.what_details)
    expect(latest_deploy.sha).to eq(first_deploy.sha)
  end
end
