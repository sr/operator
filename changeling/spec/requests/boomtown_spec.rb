require "rails_helper"

describe "Boomtown Spec", :type => :request do
  describe "GET /boomtown" do
    it "raises and exception and reports to rollbar" do
      expect do
        get "/boomtown"
      end.to raise_error { RuntimeError }
    end
  end
end
