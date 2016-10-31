require "rails_helper"

RSpec.describe Project do
  describe "#builds" do
    context "bamboo project and bamboo plan specified" do
      let(:project) do
        FactoryGirl.create(:project,
          bamboo_project: "PDT",
          bamboo_plan: "PPANT",
        )
      end

      it "searches for artifacts restricted to the specified bamboo project and bamboo plan" do
        allow(Artifactory.client).to receive(:post)
          .with("/api/search/aql", /{"@bambooProject":{"\$eq":"PDT"}},{"@bambooPlan":{"\$match":"PPANT\*"}}/, anything)
          .and_return("results" => [
            {
              "repo" => "pd-canoe",
              "path" => "PDT/PPANT",
              "name" => "build1234.tar.gz",
              "properties" => [
                { "key" => "gitBranch", "value" => "master" },
                { "key" => "buildNumber", "value" => "1234" },
                { "key" => "gitSha", "value" => "abc123" },
                { "key" => "buildTimeStamp", "value" => "2015-09-11T18:51:37.047-04:00" }
              ]
            }
          ])

        builds = project.builds(branch: "master")
        expect(builds.length).to eq(1)
        expect(builds[0].build_number).to eq(1234)
      end

      it "searches for artifacts restricted to the specified bamboo project, plan, job" do
        project.update_attributes!(bamboo_job: "JOB")
        allow(Artifactory.client).to receive(:post)
          .with("/api/search/aql", /{"@bambooProject":{"\$eq":"PDT"}},{"@bambooPlan":{"\$match":"PPANT\*"}},{"@bambooJob":{"\$eq":"JOB"}}/, anything)
          .and_return("results" => [
            {
              "repo" => "pd-canoe",
              "path" => "PDT/PPANT",
              "name" => "build1234.tar.gz",
              "properties" => [
                { "key" => "gitBranch", "value" => "master" },
                { "key" => "buildNumber", "value" => "1234" },
                { "key" => "gitSha", "value" => "abc123" },
                { "key" => "buildTimeStamp", "value" => "2015-09-11T18:51:37.047-04:00" }
              ]
            }
          ])

        builds = project.builds(branch: "master")
        expect(builds.length).to eq(1)
        expect(builds[0].build_number).to eq(1234)
      end
    end
  end

  it "excludes terraform from list of enabled projects" do
    project = FactoryGirl.create(:project)
    expect(Project.enabled).to eq([project])
    TerraformProject.create!(name: "aws/pardotops", project: project)
    expect(Project.enabled).to eq([])
  end
end
