require "rails_helper"

RSpec.describe "/api/terraform/deploys" do
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

  it "returns the deploy id if successful" do
    create_deploy estate: "aws/pardotops"

    expect(json_response["error"]).to eq(false)
    expect(json_response["deploy_id"]).to_not be_nil
  end

  it "notifies BREAD and Ops room of ongoing deploys" do
    expect(@notifier.messages.size).to eq(0)
    create_deploy estate: "aws/pardotops"
    expect(@notifier.messages.size).to eq(2)

    m = @notifier.messages.pop
    expect(m.room_id).to eq(42)
    expect(m.message).to include("is deploying")
    expect(m.message).to include("deadbeef")
    expect(m.message).to include("master")
    expect(m.message).to include("aws/pardotops")
    expect(m.message).to include("John Doe")

    m = @notifier.messages.pop
    expect(m.room_id).to eq(6)
  end
end
