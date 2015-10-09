require "rails_helper"

RSpec.describe "/api/targets/:target_name/deploys" do
  before do
    @repo = FactoryGirl.create(:repo)
    @target = FactoryGirl.create(:deploy_target, name: "test")
  end

  describe "/api/targets/:target_name/repos/:repo_name/deploys" do
    describe "without authentication" do
      it "should error" do
        get "/api/targets/#{@target.name}/repos/#{@repo.name}/deploys"
        assert_json_error_response("auth token")
      end
    end

    describe "with authentication" do
      it "returns the latest deploys" do
        deploys = FactoryGirl.create_list(:deploy, 3, deploy_target: @target, repo_name: @repo.name)

        api_get "/api/targets/#{@target.name}/repos/#{@repo.name}/deploys"
        expect(json_response.length).to eq(3)
      end
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
      describe "without repo_name" do
        it "should error" do
          api_get "/api/targets/#{@target.name}/deploys/latest"
          assert_json_error_response("Invalid repo")
        end
      end

      describe "with a bogus repo name" do
        it "should error" do
          api_get "/api/targets/#{@target.name}/deploys/latest?repo_name=foobar"
          assert_json_error_response("Invalid repo")
        end
      end

      describe "with a good repo name" do
        it "should list the latest deploy info" do
          deploy = FactoryGirl.create(:deploy, repo_name: @repo.name, deploy_target: @target)

          api_get "/api/targets/#{@target.name}/deploys/latest?repo_name=#{CGI.escape(@repo.name)}"
          assert_nonerror_response
        end
      end
    end
  end

  describe "/api/repos/:repo_name/deploys/:id" do
    describe "with a valid deploy id" do
      it "lists the servers used for deployment" do
        server = FactoryGirl.create(:server)

        deploy = FactoryGirl.create(:deploy,
          repo_name: @repo.name,
          deploy_target: @target,
          specified_servers: "localhost,#{server.hostname}",
          servers_used: "localhost",
          completed: false,
        )
        deploy.results.create!(server: server, stage: "initiated")

        api_get "/api/targets/#{@target.name}/deploys/#{deploy.id}"
        expect(json_response["servers"].keys).to match_array([server.hostname])
        expect(json_response["servers"][server.hostname]).to eq({
          "stage"  => "initiated",
          "action" => "deploy",
        })
      end
    end
  end
end
