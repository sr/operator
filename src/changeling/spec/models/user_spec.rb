require "rails_helper"

RSpec.describe User, :type => :model do
  before do
    @auth = {
      "uid" => "12345",
      "credentials" => {
        "token" => "abc123"
      },
      "extra" => {
        "raw_info" => {
          "login" => "joe"
        }
      }
    }
  end

  describe "create_with_omniauth" do
    context "with valid heroku org member" do
      before do
        expect_any_instance_of(Clients::GitHub).to receive(:heroku_org_member?).and_return(true)
        @user = User.create_with_omniauth(@auth)
      end

      it "stores encrypted_github_token" do
        verifier = Fernet.verifier(ENV["FERNET_SECRET"], @user.encrypted_github_token)
        expect(verifier.message).to eq("abc123")
      end

      it "decrypts via github_token" do
        expect(@user.github_token).to eq("abc123")
      end
    end

    it "raises if not herokai org member" do
      expect_any_instance_of(Clients::GitHub).to receive(:heroku_org_member?).and_return(false)
      expect do
        @user = User.create_with_omniauth(@auth)
      end.to raise_error("Not a Heroku organization member")
    end

    it "creates if herokai org member" do
      expect_any_instance_of(Clients::GitHub).to receive(:heroku_org_member?).and_return(true)
      expect do
        @user = User.create_with_omniauth(@auth)
      end.not_to raise_error
    end
  end

  describe "import from_csv" do
    it "works" do
      users = User.import_from_csv
      expect(users["ys"].email).to eql("yannick@heroku.com")
      expect(users["atmos"].email).to eql("corey@heroku.com")
    end
  end

  describe "for_github_login" do
    it "works" do
      expect(User.for_github_login("ys")).to eql("yannick@heroku.com")
      expect(User.for_github_login("atmos")).to eql("corey@heroku.com")
    end

    it "returns the login if we can't find the email in the csv" do
      expect(User.for_github_login("tenderlove")).to eql("tenderlove")
    end

    it "returns the login if we can't find the email in the csv" do
      expect(User.for_github_login("lynnandtonic")).to eql("lynnandtonic")
    end
  end

  describe ".for_heroku_email" do
    it "returns user if we have an employee mapping for github and email" do
      ys = User.create(github_login: "ys")
      expect(User.for_heroku_email("yannick@heroku.com")).to eql ys
    end

    it "returns nil if we have no employee mapping for github and email" do
      User.create(github_login: "lol")
      expect(User.for_heroku_email("yannick@heroku.com")).to eql nil
    end
  end
end
