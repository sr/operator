require "rails_helper"

RSpec.describe "/api/projects/:project_name/branches/:branch_name/builds" do
  before do
    @project = FactoryGirl.create(:project)
  end

  describe "without authentication" do
    it "returns an error" do
      get "/api/projects/#{@project.name}/branches/master/builds"
      assert_json_error_response("auth token")
    end
  end

  describe "with authentication" do
    it "returns the latest builds for the given project and branch" do
      allow(Artifactory.client).to receive(:post)
        .and_return("results" => [
        {
          "repo" => "pd-canoe",
          "path" => "PDT/PPANT",
          "name" => "build1234.tar.gz",
          "properties" => [
            { "key" => "gitBranch", "value" => "master" },
            { "key" => "gitRepo", "value" => "https://git.dev.pardot.com/Pardot/bread.git" },
            { "key" => "buildNumber", "value" => "1234" },
            { "key" => "gitSha", "value" => "bcd234" },
            { "key" => "buildTimeStamp", "value" => "2015-09-11T18:51:37.047-04:00" }
          ]
        }
      ])

      api_get "/api/projects/#{@project.name}/branches/master/builds"
      expect(json_response.length).to eq(1)
      expect(json_response[0]["build_number"]).to eq(1234)
      expect(json_response[0]["repo"]).to eq("https://git.dev.pardot.com/Pardot/bread.git")
    end
  end
end
