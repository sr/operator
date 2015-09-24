require "rails_helper"

RSpec.describe Repo do
  describe "#builds" do
    context "bamboo project and bamboo plan specified" do
      let(:repo) do
        FactoryGirl.create(:repo,
          bamboo_project: "PDT",
          bamboo_plan: "PPANT",
          deploys_via_artifacts: true,
        )
      end

      it "searches for artifacts restricted to the specified bamboo project and bamboo plan" do
        allow(Artifactory.client).to receive(:post)
          .with("/api/search/aql", %r({"@bambooProject":{"\$eq":"PDT"}},{"@bambooPlan":{"\$match":"PPANT\*"}}), anything)
          .and_return("results" => [
            {"repo" => "pd-canoe", "path" => "PDT/PPANT", "name" => "build1234.tar.gz"},
          ])

        allow(Artifactory.client).to receive(:get)
          .with(%r{pd-canoe/PDT/PPANT/build1234.tar.gz}, anything)
          .and_return(
            "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
            "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
            "properties" => {
              "gitBranch"      => ["master"],
              "buildNumber"    => ["1234"],
              "gitSha"         => ["abc123"],
              "buildTimeStamp" => ["2015-09-11T18:51:37.047-04:00"],
            },
          )

        builds = repo.builds(branch: "master")
        expect(builds.length).to eq(1)
        expect(builds[0].build_number).to eq(1234)
      end
    end
  end
end
