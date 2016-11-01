require "rails_helper"

RSpec.describe "Authentication API" do
  before do
    @user = FactoryGirl.create(:auth_user, email: "user@salesforce.com")
    Canoe.salesforce_authenticator.authentication_status = { granted: true }
    Api::AuthenticationController.max_tries = 1
    Api::AuthenticationController.sleep_interval = 0
  end

  def authenticate(email)
    request = Canoe::PhoneAuthenticationRequest.new(user_email: email)
    post "/api/grpc/phone_authentication", params: request.as_json, as: :json
  end

  def auth_response
    Canoe::PhoneAuthenticationResponse.decode_json(response.body)
  end

  it "returns error if the user does not have an account" do
    authenticate "nobody@salesforce.com"
    expect(auth_response["error"]).to eq(true)
    expect(auth_response["message"]).to include("No user with email \"nobody@salesforce.com")
  end

  it "returns an error if the user doesn't have a phone pairing" do
    authenticate @user.email
    expect(auth_response["error"]).to eq(true)
    expect(auth_response["user_email"]).to eq(@user.email)
    expect(auth_response["message"]).to include("https://canoe.dev.pardot.com/auth/phone")
  end

  it "returns an error if the phone authentication fails" do
    @user.phone.create_pairing("boom town")
    Canoe.salesforce_authenticator.authentication_status = { granted: false }
    authenticate @user.email
    expect(auth_response["error"]).to eq(true)
    expect(auth_response["user_email"]).to eq(@user.email)
    expect(auth_response["message"]).to eq("Phone authentication failed")
  end

  it "returns a successful response" do
    @user.phone.create_pairing("boom town")
    Canoe.salesforce_authenticator.authentication_status = { granted: true }
    authenticate @user.email

    expect(auth_response["error"]).to eq(false)
    expect(auth_response["message"]).to eq("")
    expect(auth_response["user_email"]).to eq(@user.email)
  end
end
