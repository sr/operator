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
      allow(Artifactory.client).to receive(:get)
        .with(/pd-canoe\/PDT\/PPANT\/build1234\.tar\.gz/, properties: nil)
        .and_return(
          "uri" => "https://artifactory.example/api/storage/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "download_uri" => "https://artifactory.example/pd-canoe/PDT/PPANT/build1234.tar.gz",
          "properties" => {
            "gitBranch"      => ["master"],
            "buildNumber"    => ["1234"],
            "gitSha"         => ["abc123"],
            "buildTimeStamp" => ["2015-09-11T18:51:37.047-04:00"]
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
