require "rails_helper"
require "bamboo/client"

RSpec.describe Bamboo::Client do
  describe "#create_plan_branch" do
    it "creates a plan branch for the given project key, build key, and branch" do
      client = Bamboo::Client.new(
        url: "http://bamboo.example",
        username: "username",
        password: "password",
      )

      request = stub_request(:put, "http://bamboo.example/rest/api/latest/plan/PDT-PPANT/branch/alindeman-customer-success?vcsBranch=refs/heads/alindeman/customer-success")

      res = client.create_plan_branch(
        project_key: "PDT",
        build_key: "PPANT",
        branch: "alindeman/customer-success",
      )

      expect(res).to be_truthy
      expect(request).to have_been_made.once
    end

    it "returns OK if the PUT fails, but because the branch already is being built" do
      # Bamboo's API does the absolutely wrong thing here by returning an HTTP
      # 500 when PUTing for an existing branch, but we deal with it because we
      # must
      client = Bamboo::Client.new(
        url: "http://bamboo.example",
        username: "username",
        password: "password",
      )

      request = stub_request(:put, "http://bamboo.example/rest/api/latest/plan/PDT-PPANT/branch/alindeman-customer-success?vcsBranch=refs/heads/alindeman/customer-success")
        .to_return(status: 500, body: "<message>Error: branchName: [This name is already used in a branch or plan.]</message>")

      res = client.create_plan_branch(
        project_key: "PDT",
        build_key: "PPANT",
        branch: "alindeman/customer-success",
      )

      expect(res).to be_truthy
      expect(request).to have_been_made.once
    end

    it "raises an exception for other errors" do
      client = Bamboo::Client.new(
        url: "http://bamboo.example",
        username: "username",
        password: "password",
      )

      request = stub_request(:put, "http://bamboo.example/rest/api/latest/plan/PDT-PPANT/branch/alindeman-customer-success?vcsBranch=refs/heads/alindeman/customer-success")
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
end
