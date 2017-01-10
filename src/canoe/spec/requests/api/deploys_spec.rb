require "rails_helper"

RSpec.describe "/api/targets/:target_name/deploys" do
  before do
    @project = FactoryGirl.create(:project)
    @target = FactoryGirl.create(:deploy_target, name: "test")
  end

  describe "/api/targets/:target_name/projects/:project_name/deploys" do
    describe "without authentication" do
      it "should error" do
        get "/api/targets/#{@target.name}/projects/#{@project.name}/deploys"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      it "returns the latest deploys" do
        FactoryGirl.create_list(:deploy, 3, deploy_target: @target, project_name: @project.name)

        api_get "/api/targets/#{@target.name}/projects/#{@project.name}/deploys"
        expect(json_response.length).to eq(3)
      end
    end
  end

  describe "POST /api/targets/:target_name/deploys" do
    it "requires a user" do
      api_post "/api/targets/#{@target.name}/deploys", project_name: @project.name
      expect(json_response["error"]).to eq(true)
      expect(json_response["message"]).to match(/No user with email/)
    end

    it "creates a deploy" do
      FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
      expect_any_instance_of(AuthUser).to receive(:deploy_authorized?).and_return(true)
      allow(Artifactory.client).to receive(:get)
        .with(/pd-canoe\/PDT\/PPANT\/build1234\.tar\.gz/, properties: nil)
        .and_return(
          "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "properties" => {
            "gitBranch"      => ["master"],
            "buildNumber"    => ["1234"],
            "gitSha"         => ["abc123"],
            "buildTimeStamp" => [Time.now.iso8601]
          },
        )

      api_post "/api/targets/#{@target.name}/deploys",
        artifact_url: "https://artifactory/pd-canoe/PDT/PPANT/build1234.tar.gz",
        project_name: @project.name

      expect(json_response["error"]).to eq(false)
      expect(json_response["message"]).to eq(nil)
      expect(json_response["deploy"]).to_not be(nil)
      expect(json_response["deploy"]["artifact_url"]).to eq("https://artifactory/pd-canoe/PDT/PPANT/build1234.tar.gz")
    end

    it "disallows unauthorized user" do
      deploys = Deploy.count

      FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
      expect_any_instance_of(AuthUser).to receive(:deploy_authorized?).and_return(false)
      allow(Artifactory.client).to receive(:get)
        .with(/pd-canoe\/PDT\/PPANT\/build1234\.tar\.gz/, properties: nil)
        .and_return(
          "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "properties" => {
            "gitBranch"      => ["master"],
            "buildNumber"    => ["1234"],
            "gitSha"         => ["abc123"],
            "buildTimeStamp" => [Time.now.iso8601]
          },
        )

      api_post "/api/targets/#{@target.name}/deploys",
        artifact_url: "https://artifactory/pd-canoe/PDT/PPANT/build1234.tar.gz",
        project_name: @project.name

      expect(json_response["error"]).to eq(true)
      expect(json_response["message"]).to eq("User sveader@salesforce.com is not authorized to deploy")
      expect(json_response["deploy"]).to eq(nil)

      expect(Deploy.count).to eq(deploys)
    end

    it "disallows a non-compliant build" do
      Canoe.config.github_client.compliance_state = GithubRepository::FAILURE

      FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
      expect_any_instance_of(AuthUser).to receive(:deploy_authorized?).and_return(true)
      allow(Artifactory.client).to receive(:get)
        .with(/pd-canoe\/PDT\/PPANT\/build1234\.tar\.gz/, properties: nil)
        .and_return(
          "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "properties" => {
            "gitBranch"      => ["feature-branch"],
            "buildNumber"    => ["1234"],
            "gitSha"         => ["abc123"],
            "buildTimeStamp" => [Time.now.iso8601]
          },
        )

      api_post "/api/targets/#{@target.name}/deploys",
        artifact_url: "https://artifactory/pd-canoe/PDT/PPANT/build1234.tar.gz",
        project_name: @project.name

      expect(json_response["error"]).to eq(true)
      expect(json_response["message"]).to eq("Build does not meet compliance requirements: description")
      expect(json_response["deploy"]).to eq(nil)

      expect(Deploy.count).to eq(0)
    end

    it "disallows a build that is too old" do
      FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
      expect_any_instance_of(AuthUser).to receive(:deploy_authorized?).and_return(true)
      allow(Artifactory.client).to receive(:get)
        .with(/pd-canoe\/PDT\/PPANT\/build1234\.tar\.gz/, properties: nil)
        .and_return(
          "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "properties" => {
            "gitBranch"      => ["feature-branch"],
            "buildNumber"    => ["1234"],
            "gitSha"         => ["abc123"],
            "buildTimeStamp" => [(Time.now - DeployRequest::MAXIMUM_BUILD_AGE - 1.hour).iso8601]
          },
        )

      api_post "/api/targets/#{@target.name}/deploys",
        artifact_url: "https://artifactory/pd-canoe/PDT/PPANT/build1234.tar.gz",
        project_name: @project.name

      expect(json_response["error"]).to eq(true)
      expect(json_response["message"]).to match("Build cannot be deployed because it was created more than 12 hours ago")
      expect(json_response["deploy"]).to eq(nil)

      expect(Deploy.count).to eq(0)
    end

    it "allows a non-compliant build if the project is configured to allow it" do
      @project.update!(compliant_builds_required: false)
      Canoe.config.github_client.compliance_state = GithubRepository::FAILURE

      FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
      expect_any_instance_of(AuthUser).to receive(:deploy_authorized?).and_return(true)
      allow(Artifactory.client).to receive(:get)
        .with(/pd-canoe\/PDT\/PPANT\/build1234\.tar\.gz/, properties: nil)
        .and_return(
          "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "properties" => {
            "gitBranch"      => ["feature-branch"],
            "buildNumber"    => ["1234"],
            "gitSha"         => ["abc123"],
            "buildTimeStamp" => [Time.now.iso8601]
          },
        )

      api_post "/api/targets/#{@target.name}/deploys",
        artifact_url: "https://artifactory/pd-canoe/PDT/PPANT/build1234.tar.gz",
        project_name: @project.name

      expect(json_response["error"]).to eq(false)
      expect(json_response["message"]).to eq(nil)
      expect(json_response["deploy"]).to_not be(nil)

      expect(Deploy.count).to eq(1)
    end

    it "allows a non-compliant build if deploying from the default branch" do
      Canoe.config.github_client.compliance_state = GithubRepository::FAILURE

      FactoryGirl.create(:auth_user, email: "sveader@salesforce.com")
      expect_any_instance_of(AuthUser).to receive(:deploy_authorized?).and_return(true)
      allow(Artifactory.client).to receive(:get)
        .with(/pd-canoe\/PDT\/PPANT\/build1234\.tar\.gz/, properties: nil)
        .and_return(
          "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "properties" => {
            "gitBranch"      => ["master"],
            "buildNumber"    => ["1234"],
            "gitSha"         => ["abc123"],
            "buildTimeStamp" => [Time.now.iso8601]
          },
        )

      api_post "/api/targets/#{@target.name}/deploys",
        artifact_url: "https://artifactory/pd-canoe/PDT/PPANT/build1234.tar.gz",
        project_name: @project.name

      expect(json_response["error"]).to eq(false)
      expect(json_response["message"]).to eq(nil)
      expect(json_response["deploy"]).to_not be(nil)

      expect(Deploy.count).to eq(1)
    end
  end

  describe "/api/targets/:target_name/deploys/latest" do
    describe "without authentication" do
      it "should error" do
        get "/api/targets/#{@target.name}/deploys/latest"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      describe "without project_name" do
        it "should error" do
          api_get "/api/targets/#{@target.name}/deploys/latest"
          assert_json_error_response("Invalid project")
        end
      end

      describe "with a bogus project name" do
        it "should error" do
          api_get "/api/targets/#{@target.name}/deploys/latest?project_name=foobar"
          assert_json_error_response("Invalid project")
        end
      end

      describe "with a good project name" do
        it "should list the latest deploy info" do
          FactoryGirl.create(:deploy, project_name: @project.name, deploy_target: @target)

          api_get "/api/targets/#{@target.name}/deploys/latest?project_name=#{CGI.escape(@project.name)}"
          assert_nonerror_response
        end

        it "lists the servers used for deployment" do
          server = FactoryGirl.create(:server)

          deploy = FactoryGirl.create(:deploy,
            project_name: @project.name,
            deploy_target: @target,
            specified_servers: "localhost,#{server.hostname}",
            servers_used: "localhost",
            completed: false
          )
          deploy.results.create!(server: server, stage: "initiated")

          api_get "/api/targets/#{@target.name}/deploys/latest?project_name=#{CGI.escape(@project.name)}"
          expect(json_response["servers"].keys).to match_array([server.hostname])
        end
      end
    end
  end

  describe "/api/projects/:project_name/deploys/:id" do
    describe "with a valid deploy id" do
      it "lists the servers used for deployment" do
        server = FactoryGirl.create(:server)

        deploy = FactoryGirl.create(:deploy,
          project_name: @project.name,
          deploy_target: @target,
          specified_servers: "localhost,#{server.hostname}",
          servers_used: "localhost",
          completed: false,
          options: { "foo" => "bar" })
        deploy.results.create!(server: server, stage: "initiated")

        api_get "/api/targets/#{@target.name}/deploys/#{deploy.id}"
        expect(json_response["servers"].keys).to match_array([server.hostname])
        expect(json_response["servers"][server.hostname]).to eq("stage" => "initiated",
                                                                "action" => "deploy")
        expect(json_response["options"]).to eq("foo" => "bar")
      end
    end
  end
end
