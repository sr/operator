require "rails_helper"

RSpec.describe "Terraform API" do
  before do
    @project = TerraformProject.create!
    @user = FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
    @notifier = FakeHipchatNotifier.new
    Api::TerraformController.notifier = @notifier
    TerraformProject.required_version = nil
  end

  def create_deploy(params)
    default_params = {
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

  def complete_deploy(deploy_id, successful)
    request = Canoe::CompleteTerraformDeployRequest.new(
      user_email: @user.email,
      deploy_id: deploy_id.to_i,
      successful: successful
    )

    post "/api/grpc/complete_terraform_deploy",
      params: request.as_json,
      as: :json,
      headers: { "HTTP_X_API_TOKEN" => ENV["API_AUTH_TOKEN"] }
  end

  def create_deploy_response
    Canoe::CreateTerraformDeployResponse.decode_json(response.body)
  end

  def complete_deploy_response
    Canoe::CompleteTerraformDeployResponse.decode_json(response.body)
  end

  it "returns an error for unknown user" do
    create_deploy user_email: "unknown@salesforce.com"

    expect(create_deploy_response["error"]).to eq(true)
    expect(create_deploy_response["message"]).to match(/No user with email/)
  end

  it "returns an error if the current version doesn't match the required terraform version" do
    create_deploy estate: "aws/pardot-ci", terraform_version: "0"

    expect(create_deploy_response["error"]).to eq(true)
    expect(create_deploy_response["message"]).to match(/Terraform version/)
  end

  it "returns an error for unknown estates" do
    create_deploy estate: "aws/boomtown"

    expect(create_deploy_response["error"]).to eq(true)
    expect(create_deploy_response["message"]).to eq("Unknown Terraform estate: \"aws/boomtown\"")
  end

  it "returns an error if the estate is locked" do
    create_deploy estate: "aws/pardotops"
    expect(create_deploy_response["error"]).to eq(false)
    expect(create_deploy_response["message"]).to eq("")

    create_deploy estate: "aws/pardotops"
    expect(create_deploy_response["error"]).to eq(true)
    expect(create_deploy_response["message"]).to include("aws/pardotops")
    expect(create_deploy_response["message"]).to include("locked by John Doe")
  end

  it "notifies HipChat of successful deploys" do
    @project.deploy_notifications.create!(hipchat_room_id: 42)

    create_deploy estate: "aws/pardotops"
    complete_deploy(create_deploy_response["deploy_id"], true)

    expect(complete_deploy_response["error"]).to eq(false)
    expect(complete_deploy_response["deploy_id"]).to_not be_nil

    m = @notifier.messages.pop
    expect(m.message).to include("John Doe")
    expect(m.message).to include("aws/pardotops")
    expect(m.message).to include("is done")
  end

  it "notifies HipChat of failed deploys" do
    @project.deploy_notifications.create!(hipchat_room_id: 42)

    create_deploy estate: "aws/pardotops"
    complete_deploy(json_response["deploy_id"], false)

    expect(complete_deploy_response["error"]).to eq(false)
    expect(complete_deploy_response["deploy_id"]).to_not be_nil

    m = @notifier.messages.pop
    expect(m.message).to include("failed")
  end

  it "returns an error when the deploy is already complete" do
    create_deploy estate: "aws/pardotops"
    complete_deploy(json_response["deploy_id"], true)
    complete_deploy(json_response["deploy_id"], true)

    expect(complete_deploy_response["error"]).to eq(true)
    expect(complete_deploy_response["message"]).to eq("Deploy is already complete")
    expect(complete_deploy_response["deploy_id"]).to_not be(nil)
  end

  it "notifies HipChat of ongoing deploys" do
    @project.deploy_notifications.create!(hipchat_room_id: 42)

    expect(@notifier.messages.size).to eq(0)
    create_deploy estate: "aws/pardotops"
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