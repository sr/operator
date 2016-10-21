require "rails_helper"

RSpec.describe "Terraform API" do
  before do
    @project = TerraformProject.create!
    @user = FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
    @notifier = FakeHipchatNotifier.new
    Api::TerraformDeploysController.notifier = @notifier
  end

  def create_deploy(params)
    default_params = {
      user_email: @user.email,
      branch: "master",
      commit: "deadbeef",
      terraform_version: "0.7.4"
    }

    api_post "/api/terraform/deploys", default_params.merge(params)
  end

  def complete_deploy(deploy_id, successful)
    api_post "/api/terraform/complete_deploy", deploy_id: deploy_id, successful: successful
  end

  it "returns an error for unknown user" do
    create_deploy user_email: "unknown@salesforce.com"

    expect(json_response["error"]).to eq(true)
    expect(json_response["message"]).to match(/No user with email/)
  end

  it "returns an error for unknown estates" do
    create_deploy estate: "aws/boomtown"

    expect(json_response["error"]).to eq(true)
    expect(json_response["message"]).to eq("Unknown Terraform estate: \"aws/boomtown\"")
  end

  it "returns an error if the estate is locked" do
    create_deploy estate: "aws/pardotops"
    expect(json_response["error"]).to eq(false)
    expect(json_response["message"]).to eq("")

    create_deploy estate: "aws/pardotops"
    json_response = JSON.parse(response.body)
    expect(json_response["error"]).to eq(true)
    expect(json_response["message"]).to include("aws/pardotops")
    expect(json_response["message"]).to include("locked by John Doe")
  end

  it "notifies HipChat of successful deploys" do
    @project.deploy_notifications.create!(hipchat_room_id: 42)

    create_deploy estate: "aws/pardotops"
    complete_deploy(json_response["deploy_id"], true)

    expect(json_response["error"]).to eq(false)
    expect(json_response["deploy_id"]).to_not be_nil

    m = @notifier.messages.pop
    expect(m.message).to include("John Doe")
    expect(m.message).to include("aws/pardotops")
    expect(m.message).to include("is done")
  end

  it "notifies HipChat of failed deploys" do
    @project.deploy_notifications.create!(hipchat_room_id: 42)

    create_deploy estate: "aws/pardotops"
    complete_deploy(json_response["deploy_id"], false)

    expect(json_response["error"]).to eq(false)
    expect(json_response["deploy_id"]).to_not be_nil

    m = @notifier.messages.pop
    expect(m.message).to include("failed")
  end

  it "returns an error when the deploy is already complete" do
    create_deploy estate: "aws/pardotops"
    complete_deploy(json_response["deploy_id"], true)
    complete_deploy(json_response["deploy_id"], true)

    json_response = JSON.parse(response.body)
    expect(json_response["error"]).to eq(true)
    expect(json_response["message"]).to eq("Deploy is already complete")
    expect(json_response["deploy_id"]).to_not be(nil)
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
