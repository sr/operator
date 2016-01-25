require "rails_helper"

RSpec.feature "user deploys murdoc repo from artifactory artifact" do
  before do
    @deploy_target = FactoryGirl.create(:deploy_target, name: "test")
    @repo = FactoryGirl.create(:repo,
      name: "murdoc",
      deploys_via_artifacts: true,
      bamboo_project: "PDT",
      bamboo_plan: "MDOC",
    )
    @server = FactoryGirl.create(:server, hostname: "nimbus-s1.example")
    @server.deploy_scenarios.create!(deploy_target: @deploy_target, repo: @repo)

    @options_validator = Base64.encode64('
      {
        "properties": {
          "topology": {
            "enum": [
              "murdoc-topo:murdoc.processing.topology.MurdocTopology",
              "action-topo:murdoc.processing.topology.ActionApplicationTopology",
              "reporting-topo:murdoc.reporting.topology.MurdocReportingTopology"
            ]
          }
        },
        "required": [
          "topology"
        ],
        "type": "object"
      }
    ')

    allow(Octokit).to receive(:branch)
      .with("Pardot/#{@repo.name}", "master")
      .and_return(OpenStruct.new(name: "master", object: OpenStruct.new(sha: "abc123")))

    allow(Artifactory.client).to receive(:post)
      .and_return("results" => [
        {
          "repo" => "pd-canoe",
          "path" => "PDT/MDOC",
          "name" => "build1234.tar.gz",
          "properties" => [
            {"key" => "gitBranch", "value" => "master"},
            {"key" => "buildNumber", "value" => "1234"},
            {"key" => "gitSha", "value" => "abc123"},
            {"key" => "buildTimeStamp", "value" => "2015-09-11T18:51:37.047-04:00"},
            {"key" => "optionsValidator", "value" => @options_validator}
          ]
        },
      ])

    allow(Artifactory.client).to receive(:get)
      .with(%r{pd-canoe/PDT/MDOC/build1234.tar.gz}, properties: nil)
      .and_return(
        "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/MDOC/build1234.tar.gz",
        "download_uri" => "https://artifactory.example/pd-canoe/PDT/MDOC/build1234.tar.gz",
        "properties" => {
          "gitBranch"        => ["master"],
          "buildNumber"      => ["1234"],
          "gitSha"           => ["abc123"],
          "buildTimeStamp"   => ["2015-09-11T18:51:37.047-04:00"],
          "optionsValidator" => [@options_validator],
        },
      )
  end

  scenario "happy path deployment" do
    login_as "Joe Syncmaster", "joe.syncmaster@salesforce.com"

    find(".repos a", text: @repo.name.capitalize).click
    find(".deploy-targets a", text: "master").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship it Here").click
    find("option", text: "murdoc-topo").select_option
    click_button "SHIP IT!"
    expect(page).to have_text("Watching deploy of #{@repo.name.capitalize}")

    deploys = Deploy.all
    expect(deploys.length).to eq(1)
    expect(deploys[0].options).to eq("topology" => "murdoc-topo:murdoc.processing.topology.MurdocTopology")
  end
end
