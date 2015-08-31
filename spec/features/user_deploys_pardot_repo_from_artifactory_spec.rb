require "rails_helper"

RSpec.feature "user deploys pardot repo from artifactory artifact" do
  before do
    FactoryGirl.create(:deploy_target, name: "test")
    @repo = FactoryGirl.create(:repo, name: "pardot", artifactory_project: "pardot")

    allow(Octokit).to receive(:branch)
      .with("Pardot/#{@repo.name}", "master")
      .and_return(OpenStruct.new(name: "master", object: OpenStruct.new(sha: "abc123")))

    allow(Artifactory::Resource::Artifact).to receive(:property_search)
      .with(project: @repo.artifactory_project, branch: "master", repos: Repo::ARTIFACTORY_REPO)
      .and_return([OpenStruct.new(uri: "https://artifactory.example/pardot/build1234.tar.gz")])

    properties = {
      "branch" => ["master"],
      "build"  => ["1234"],
      "sha"    => ["abc123"],
    }
    allow(Artifactory::Resource::Artifact).to receive(:from_url)
      .with("https://artifactory.example/pardot/build1234.tar.gz")
      .and_return(OpenStruct.new(properties: properties))
  end

  scenario "happy path deployment" do
    login_as "Joe Syncmaster", "joe.syncmaster@salesforce.com"

    find(".repos a", text: @repo.name.capitalize).click
    find(".deploy-targets a", text: "master").click
    click_link "Ship This"
    find("a[data-target='test']", text: "Ship it Here").click
    click_button "SHIP IT!"
    expect(page).to have_text("Watching deploy of #{@repo.name.capitalize}")

    deploys = Deploy.all
    expect(deploys.length).to eq(1)
    expect(deploys[0].auth_user.email).to eq("joe.syncmaster@salesforce.com")
    expect(deploys[0].repo_name).to eq(@repo.name)
    expect(deploys[0].what).to eq("branch")
    expect(deploys[0].what_details).to eq("master")
    expect(deploys[0].build_number).to eq(1234)
    expect(deploys[0].server_count).to eq(1)
    expect(deploys[0].servers_used).to eq("localhost")
    expect(deploys[0].specified_servers).to eq(nil)
    expect(deploys[0].sha).to eq("abc123")
    expect(deploys[0].artifact_url).to eq("https://artifactory.example/pardot/build1234.tar.gz")
  end
end
