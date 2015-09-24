require "rails_helper"

RSpec.describe "/api/repos/:repo_name/branches/:branch_name/builds" do
  before do
    @repo = FactoryGirl.create(:repo)
  end

  describe "without authentication" do
    it "returns an error" do
      get "/api/repos/#{@repo.name}/branches/master/builds"
      assert_json_error_response("auth token")
    end
  end

  describe "with authentication" do
    it "returns the latest builds for the given repository and branch" do
      allow(Artifactory.client).to receive(:post)
        .and_return("results" => [
          {"repo" => "pd-canoe", "path" => "PDT/PPANT", "name" => "build1234.tar.gz"},
        ])

    allow(Artifactory.client).to receive(:get)
      .with(%r{pd-canoe/PDT/PPANT/build1234.tar.gz}, properties: nil)
      .and_return(
        "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
        "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
        "properties" => {
          "gitBranch"      => ["master"],
          "buildNumber"    => ["1234"],
          "gitSha"         => ["bcd234"],
          "buildTimeStamp" => ["2015-09-11T18:51:37.047-04:00"],
        },
      )

      api_get "/api/repos/#{@repo.name}/branches/master/builds"
      expect(json_response.length).to eq(1)
      expect(json_response[0]["build_number"]).to eq(1234)
    end
  end
end
