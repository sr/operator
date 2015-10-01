require "rails_helper"
require "bamboo/client"

RSpec.describe Bamboo::Client do
  let(:client) do
    Bamboo::Client.new(
      url: "http://bamboo.example",
      username: "username",
      password: "password",
    )
  end

  describe "#plan_branch" do
    it "finds information for the given branch in the project key and build key" do
      stub_request(:get, "http://username:password@bamboo.example/rest/api/latest/plan/PDT-PPANT/branch/alindeman-testing-bamboo-builds")
        .to_return(body: '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><branch expand="latestResult,master" key="PDT-PPANT372" name="Pardot - Pardot PHP and Java Services - alindeman-testing-bamboo-builds" description="" shortName="alindeman-testing-bamboo-builds" shortKey="PPANT372" enabled="true"><isFavourite>false</isFavourite><latestResult key="PDT-PPANT372-2" state="Successful" lifeCycleState="Finished" number="2" id="-1"><link href="https://bamboo.dev.pardot.com/rest/api/latest/result/PDT-PPANT372-2" rel="self"/><plan key="PDT-PPANT372" name="Pardot - Pardot PHP and Java Services - alindeman-testing-bamboo-builds" shortName="alindeman-testing-bamboo-builds" shortKey="PPANT372" type="chain_branch" enabled="true"><master key="PDT-PPANT" name="Pardot - Pardot PHP and Java Services" shortName="Pardot PHP and Java Services" shortKey="PPANT" type="chain" enabled="true"><planKey><key>PDT-PPANT</key></planKey><link href="https://bamboo.dev.pardot.com/rest/api/latest/plan/PDT-PPANT" rel="self"/></master><planKey><key>PDT-PPANT372</key></planKey><link href="https://bamboo.dev.pardot.com/rest/api/latest/plan/PDT-PPANT372" rel="self"/></plan><master key="PDT-PPANT" name="Pardot - Pardot PHP and Java Services" shortName="Pardot PHP and Java Services" shortKey="PPANT" type="chain" enabled="true"><planKey><key>PDT-PPANT</key></planKey><link href="https://bamboo.dev.pardot.com/rest/api/latest/plan/PDT-PPANT" rel="self"/></master><buildResultKey>PDT-PPANT372-2</buildResultKey><planResultKey><key>PDT-PPANT372-2</key><entityKey><key>PDT-PPANT372</key></entityKey><resultNumber>2</resultNumber></planResultKey><buildState>Successful</buildState><buildNumber>2</buildNumber></latestResult><link href="https://bamboo.dev.pardot.com/rest/api/latest/plan/PDT-PPANT372" rel="self"/><master key="PDT-PPANT" name="Pardot - Pardot PHP and Java Services" shortName="Pardot PHP and Java Services" shortKey="PPANT" type="chain" enabled="true"><planKey><key>PDT-PPANT</key></planKey><link href="https://bamboo.dev.pardot.com/rest/api/latest/plan/PDT-PPANT" rel="self"/></master></branch>')

      res = client.plan_branch(
        project_key: "PDT",
        build_key: "PPANT",
        branch: "alindeman/testing-bamboo-builds",
      )

      expect(res).to be
      expect(res[:plan_key]).to eq("PDT-PPANT372")
    end

    it "returns nil if no results are found" do
      stub_request(:get, "http://username:password@bamboo.example/rest/api/latest/plan/PDT-PPANT/branch/hindenburg")
        .to_return(status: 204, body: '')

      res = client.plan_branch(
        project_key: "PDT",
        build_key: "PPANT",
        branch: "hindenburg",
      )

      expect(res).to be_nil
    end
  end

  describe "#create_plan_branch" do
    it "creates a plan branch for the given project key, build key, and branch" do
      request = stub_request(:put, "http://username:password@bamboo.example/rest/api/latest/plan/PDT-PPANT/branch/alindeman-customer-success?vcsBranch=alindeman/customer-success")
        .to_return(body: '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><branch key="PDT-PPANT369" name="Pardot - Pardot PHP and Java Services - alindeman-customer-success" description="" shortName="alindeman-customer-success" shortKey="PPANT369" enabled="true"><link href="http://bamboo.example/rest/api/latest/plan/PDT-PPANT369" rel="self"/></branch>')

      res = client.create_plan_branch(
        project_key: "PDT",
        build_key: "PPANT",
        branch: "alindeman/customer-success",
      )

      expect(res).to be
      expect(res[:plan_key]).to eq("PDT-PPANT369")
    end

    it "raises an exception for errors" do
      request = stub_request(:put, "http://username:password@bamboo.example/rest/api/latest/plan/PDT-PPANT/branch/alindeman-customer-success?vcsBranch=alindeman/customer-success")
        .to_return(status: 500, body: "<message>Error: Something terrible happened</message>")

      expect {
        client.create_plan_branch(
          project_key: "PDT",
          build_key: "PPANT",
          branch: "alindeman/customer-success",
        )
      }.to raise_error(/Something terrible happened/)

      expect(request).to have_been_made.once
    end
  end

  describe "#latest_result" do
    it "returns the latest result for the given plan key" do
      stub_request(:get, "http://username:password@bamboo.example/rest/api/latest/result/PDT-PPANT372/latest?includeAllStates=true")
        .to_return(body: '<result expand="changes,metadata,plan,master,vcsRevisions,artifacts,comments,labels,jiraIssues,stages" key="PDT-PPANT372-4" state="Unknown" lifeCycleState="InProgress" number="4" id="25174392" continuable="false" onceOff="false" restartable="false" notRunYet="false" finished="false" successful="false"></result>')

      res = client.latest_result(
        plan_key: "PDT-PPANT372"
      )

      expect(res).to be
      expect(res[:build_result_key]).to eq("PDT-PPANT372-4")
      expect(res[:state]).to eq("unknown")
      expect(res[:life_cycle_state]).to eq("inprogress")
    end

    it "returns nil if there is no latest build" do
      stub_request(:get, "http://username:password@bamboo.example/rest/api/latest/result/PDT-PPANT372/latest?includeAllStates=true")
        .to_return(status: 404)

      res = client.latest_result(
        plan_key: "PDT-PPANT372"
      )

      expect(res).to be_nil
    end
  end

  describe "#queue_build" do
    it "queues a build for the given plan key" do
      request = stub_request(:post, "http://username:password@bamboo.example/rest/api/latest/queue/PDT-PPANT369?executeAllStages=true")
        .to_return(body: '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><restQueuedBuild planKey="PDT-PPANT369" buildNumber="2" buildResultKey="PDT-PPANT369-2"><triggerReason>Manual build</triggerReason><link href="http://bamboo.example/rest/api/latest/result/PDT-PPANT369-2" rel="self"/></restQueuedBuild>')

      res = client.queue_build(
        plan_key: "PDT-PPANT369",
      )

      expect(res).to be
      expect(res[:build_result_key]).to eq("PDT-PPANT369-2")
    end
  end
end
