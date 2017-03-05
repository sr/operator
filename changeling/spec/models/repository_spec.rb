require "rails_helper"

RSpec.describe Repository, :type => :model do
  let(:default_room) { "Tools-ops" }
  before do
    stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))
  end

  describe ".team_for" do
    it "identifies teams for valid repositories" do
      expect(Repository.team_for("heroku/heimdall")).to eql("Tools")
      expect(Repository.team_for("heroku/caas")).to eql("Foundation")
    end

    it "returns 'Unknown' when it can't find a repository" do
      expect(Repository.team_for("heroku/whatevers")).to eql("Unknown")
    end

    it "returns 'Unknown' when the team is blank" do
      expect(Repository.team_for("heroku/pg_logplexcollector")).to eql("Unknown")
    end
  end

  describe ".participating?" do
    it "returns true for heroku/changeling" do
      expect(Repository.participating?("heroku/changeling")).to be true
    end

    it "returns false for heroku/changeling-pr-tests" do
      expect(Repository.participating?("heroku/changeling-pr-tests")).to be false
    end

    it "returns false for unknown repositories" do
      expect(Repository.participating?("heroku/supercalafragalisticexpialadoshus")).to be false
    end
  end
end
