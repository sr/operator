require "rails_helper"

RSpec.feature "user deploys pardot project from artifactory artifact" do
  SYNCMASTER = "joe.syncmaster@salesforce.com".freeze

  before do
    @deploy_target = FactoryGirl.create(:deploy_target, name: "test")
    @project = FactoryGirl.create(:project,
      name: "pardot",
      bamboo_project: "PDT",
      bamboo_plan: "PPANT"
    )
    @server = FactoryGirl.create(:server, hostname: "app-s1.example")
    @server.deploy_scenarios.create!(deploy_target: @deploy_target, project: @project)

    allow(Octokit).to receive(:branch)
      .with("Pardot/#{@project.name}", "master")
      .and_return(OpenStruct.new(name: "master", object: OpenStruct.new(sha: "abc123")))

    allow(Artifactory.client).to receive(:post)
      .and_return("results" => [
        {
          "repo" => "pd-canoe",
          "path" => "PDT/PPANT",
          "name" => "build1234.tar.gz",
          "properties" => [
            { "key" => "gitBranch", "value" => "master" },
            { "key" => "buildNumber", "value" => "1234" },
            { "key" => "gitSha", "value" => "abc123" },
            { "key" => "buildTimeStamp", "value" => "2015-09-11T18:51:37.047-04:00" }
          ]
        }
      ])

    allow(Artifactory.client).to receive(:get)
      .with(%r{pd-canoe/PDT/PPANT/build1234.tar.gz}, properties: nil)
      .and_return(
        "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
        "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
        "properties" => {
          "gitBranch"      => ["master"],
          "buildNumber"    => ["1234"],
          "gitSha"         => ["abc123"],
          "buildTimeStamp" => ["2015-09-11T18:51:37.047-04:00"]
        },
      )
  end

  scenario "happy path deployment" do
    login_as "Joe Syncmaster", SYNCMASTER

    find(".projects-index-list a", text: @project.titleized_name).click
    find(".deploy-targets a", text: "master").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship It Here").click
    expect(page).to_not have_text("Tags") # We deploy to all servers by default
    click_button "SHIP IT!"
    expect(page).to have_text("Watching deploy of #{@project.name.capitalize}")

    deploys = Deploy.all
    expect(deploys.length).to eq(1)
    expect(deploys[0].auth_user.email).to eq(SYNCMASTER)
    expect(deploys[0].project_name).to eq(@project.name)
    expect(deploys[0].branch).to eq("master")
    expect(deploys[0].build_number).to eq(1234)
    expect(deploys[0].specified_servers).to eq(nil)
    expect(deploys[0].sha).to eq("abc123")
    expect(deploys[0].artifact_url).to be_present

    expect(deploys[0].results.length).to eq(1)
    expect(deploys[0].results[0].server.hostname).to eq(@server.hostname)
    expect(deploys[0].results[0].stage).to eq("initiated")
  end

  scenario "deployment with 2FA required" do
    Canoe.config.phone_authentication_required = true

    auth_user = FactoryGirl.create(:auth_user, email: SYNCMASTER, uid: SYNCMASTER)
    auth_user.phone.create_pairing("pairing phrase")

    login_as "Joe Syncmaster", SYNCMASTER

    find(".projects-index-list a", text: @project.titleized_name).click
    find(".deploy-targets a", text: "master").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship It Here").click
    expect(page).to_not have_text("Tags") # We deploy to all servers by default
    click_button "SHIP IT!"
    expect(page).to have_text("Watching deploy of #{@project.name.capitalize}")
  end

  scenario "deployment with 2FA required and when auth fails" do
    Canoe.config.phone_authentication_required = true
    Canoe.salesforce_authenticator.authentication_status = { granted: false }

    auth_user = FactoryGirl.create(:auth_user, email: SYNCMASTER, uid: SYNCMASTER)
    auth_user.phone.create_pairing("pairing phrase")

    login_as "Joe Syncmaster", SYNCMASTER

    find(".projects-index-list a", text: @project.titleized_name).click
    find(".deploy-targets a", text: "master").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship It Here").click
    expect(page).to_not have_text("Tags") # We deploy to all servers by default
    click_button "SHIP IT!"
    expect(page).to have_text("Phone authentication failed")
  end

  scenario "deployment with 2FA required but no phone paired" do
    Canoe.config.phone_authentication_required = true
    Canoe.salesforce_authenticator.authentication_status = { granted: false }

    login_as "Joe Syncmaster", SYNCMASTER

    find(".projects-index-list a", text: @project.titleized_name).click
    find(".deploy-targets a", text: "master").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship It Here").click
    expect(page).to_not have_text("Tags") # We deploy to all servers by default
    click_button "SHIP IT!"
    expect(page).to have_text("Phone authentication failed")
  end
end
