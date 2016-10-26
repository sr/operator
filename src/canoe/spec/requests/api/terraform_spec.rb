require "rails_helper"

RSpec.describe "Terraform API" do
  before do
    @notifier = FakeHipchatNotifier.new
    TerraformProject.notifier = @notifier
    TerraformProject.required_version = "0.7.4"

    @project = TerraformProject.create!(name: "aws/pardotops", project: FactoryGirl.create(:project))
    @user = FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
    @user.phone.create_pairing("boom town")
  end

  def create_deploy(params)
    default_params = {
      project: "aws/pardotops",
      user_email: @user.email,
      branch: "master",
      commit: "deadbeef",
      terraform_version: TerraformProject.required_version
    }

    request = Canoe::CreateTerraformDeployRequest.new(default_params.merge(params))

    post "/api/grpc/create_terraform_deploy",
      params: request.as_json,
      as: :json,
      headers: { "HTTP_X_API_TOKEN" => ENV["API_AUTH_TOKEN"] }
  end

  def complete_deploy(project, request_id, successful)
    request = Canoe::CompleteTerraformDeployRequest.new(
      user_email: @user.email,
      request_id: request_id,
      project: project,
      successful: successful
    )

    post "/api/grpc/complete_terraform_deploy",
      params: request.as_json,
      as: :json,
      headers: { "HTTP_X_API_TOKEN" => ENV["API_AUTH_TOKEN"] }
  end

  def deploy_response
    Canoe::TerraformDeployResponse.decode_json(response.body)
  end

  it "requires phone authentication" do
    SalesforceAuthenticatorPairing.delete_all

    create_deploy project: "aws/pardotops"
    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to eq("Phone authentication required")
  end

  it "returns an error for unknown user" do
    create_deploy user_email: "unknown@salesforce.com"

    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to match(/No user with email/)
  end

  it "returns an error if the current version doesn't match the required terraform version" do
    create_deploy project: "aws/pardotops", terraform_version: "0"

    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to match(/Terraform version/)
  end

  it "returns an error for unknown project" do
    create_deploy project: "aws/boomtown"

    expect(deploy_response["error"]).to eq(true)
    expect(deploy_response["message"]).to eq("Unknown Terraform project: \"aws/boomtown\"")
  end

  it "returns an error if the project is locked" do
    create_deploy project: "aws/pardotops"
    expect(deploy_response.error).to eq(false)
    expect(deploy_response.message).to eq("")

    create_deploy project: "aws/pardotops"
    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to include("aws/pardotops")
    expect(deploy_response.message).to include("locked by John Doe")
  end

  it "notifies HipChat of successful deploys" do
    @project.deploy_notifications.create!(hipchat_room_id: 42)

    create_deploy project: "aws/pardotops"
    complete_deploy(deploy_response.project, deploy_response.request_id, true)

    expect(deploy_response.error).to eq(false)
    expect(deploy_response.deploy_id).to_not be_nil
    expect(deploy_response.request_id).to_not be_nil
    expect(deploy_response.request_id).to_not eq("")

    m = @notifier.messages.pop
    expect(m.message).to include("John Doe")
    expect(m.message).to include("aws/pardotops")
    expect(m.message).to include("is done")
  end

  it "notifies HipChat of failed deploys" do
    @project.deploy_notifications.create!(hipchat_room_id: 42)

    create_deploy project: "aws/pardotops"
    complete_deploy(deploy_response.project, deploy_response.request_id, false)

    expect(deploy_response.error).to eq(false)
    expect(deploy_response.deploy_id).to_not be_nil

    m = @notifier.messages.pop
    expect(m.message).to include("failed")
  end

  it "returns an error when the deploy is already complete" do
    create_deploy project: "aws/pardotops"
    complete_deploy(deploy_response.project, deploy_response.request_id, true)
    complete_deploy(deploy_response.project, deploy_response.request_id, true)

    expect(deploy_response.error).to eq(true)
    expect(deploy_response.message).to eq("Deploy is already complete")
    expect(deploy_response.deploy_id).to_not be(nil)
  end

  it "notifies HipChat of ongoing deploys" do
    @project.deploy_notifications.create!(hipchat_room_id: 42)

    expect(@notifier.messages.size).to eq(0)
    create_deploy project: "aws/pardotops"
    expect(@notifier.messages.size).to eq(1)

    m = @notifier.messages.pop
    expect(m.room_id).to eq(42)
    expect(m.message).to include("is deploying")
    expect(m.message).to include("deadbee")
    expect(m.message).to include("master")
    expect(m.message).to include("aws/pardotops")
    expect(m.message).to include("John Doe")
  end
end
