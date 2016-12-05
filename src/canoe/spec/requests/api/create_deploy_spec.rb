require "rails_helper"

RSpec.describe "Deploy creation API" do
  before do
    Canoe.config.phone_authentication_max_tries = 1
    Canoe.config.phone_authentication_sleep_interval = 0
    Canoe.salesforce_authenticator.authentication_status = { granted: true }

    @project = FactoryGirl.create(:project)
    @target = FactoryGirl.create(:deploy_target, name: "test")
    @user = FactoryGirl.create(:auth_user)
    @user.phone.create_pairing("pairing phrase")

    @default_artifact = {
      "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
      "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
      "properties" => {
        "gitBranch"      => ["master"],
        "buildNumber"    => ["1234"],
        "gitSha"         => ["abc123"],
        "buildTimeStamp" => ["2015-09-11T18:51:37.047-04:00"]
      }
    }
  end

  def stub_artifactory_client(url, artifact)
    allow(Artifactory.client).to receive(:get)
      .with(Regexp.new(URI(url).path), properties: nil)
      .and_return(artifact)
  end

  def create_deploy(params)
    default_params = {
      user_email: @user.email,
      project: @project.name,
      target_name: "production",
      artifact_url: @default_artifact.fetch("download_uri"),
      lock: false
    }

    request = Canoe::CreateDeployRequest.new(default_params.merge(params))
    post "/api/grpc/create_deploy",
      headers: { "X-Api-Token" => ENV["API_AUTH_TOKEN"] },
      params: request.as_json,
      as: :json
  end

  def deploy_response
    Canoe::CreateDeployResponse.decode_json(response.body)
  end

  it "returns an error when given no user" do
    create_deploy(user_email: "")

    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to match(/No user with email/)
  end

  it "returns an error for unknown user" do
    create_deploy(user_email: "unknown@salesforce.com")

    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to match(/No user with email/)
  end

  it "returns an error if the user doesn't have a phone pairing setup" do
    SalesforceAuthenticatorPairing.delete_all
    artifact_url = @default_artifact.fetch("download_uri")
    stub_artifactory_client(artifact_url, @default_artifact)

    create_deploy(project: @project.name, target_name: @target.name)
    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to include("Phone authentication required")
  end

  it "returns an error if the phone authentication fails" do
    Canoe.salesforce_authenticator.authentication_status = { granted: false }
    artifact_url = @default_artifact.fetch("download_uri")
    stub_artifactory_client(artifact_url, @default_artifact)

    expect(Deploy.count).to eq(0)

    create_deploy(
      target_name: @target.name,
      project: @project.name,
      artifact_url: artifact_url
    )
    expect(deploy_response["error"]).to eq(true)
    expect(deploy_response["message"]).to include("Phone authentication failed")
  end

  it "returns the new deploy after successfuly creating it" do
    artifact_url = @default_artifact.fetch("download_uri")
    expect_any_instance_of(AuthUser).to receive(:deploy_authorized?).and_return(true)
    stub_artifactory_client(artifact_url, @default_artifact)

    expect(Deploy.count).to eq(0)

    create_deploy(
      target_name: @target.name,
      project: @project.name,
      artifact_url: artifact_url
    )

    expect(deploy_response.error).to eq(false)
    expect(deploy_response.message).to eq("")
    expect(deploy_response.deploy_id).to_not eq(0)
    expect(Deploy.count).to eq(1)
  end

  it "returns an error for unauthorized user" do
    artifact_url = @default_artifact.fetch("download_uri")
    expect_any_instance_of(AuthUser).to receive(:deploy_authorized?).and_return(false)
    stub_artifactory_client(artifact_url, @default_artifact)

    create_deploy(
      target_name: @target.name,
      project: @project.name,
      artifact_url: artifact_url
    )

    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to eq("User #{@user.email} is not authorized to deploy")
    expect(deploy_response.deploy_id).to eq(0)
    expect(Deploy.count).to eq(0)
  end
end
