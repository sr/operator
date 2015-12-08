require_relative "test_helper.rb"
require "fetch_strategy_artifactory"

describe FetchStrategyArtifactory do
  before do
    @env = EnvironmentTest.new
    @env.payload = :'workflow-stats'
    @strat = FetchStrategyArtifactory.new(@env)
  end

  it "should use Artifactory to check validity of build" do
    artifact = mock
    artifact.stubs(:properties).returns("gitSha" => "abc123")

    Artifactory::Resource::Artifact
      .expects(:from_url)
      .with("https://artifactory.example/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
      .returns(artifact)

    deploy = Deploy.from_hash("artifact_url" => "https://artifactory.example/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
    assert @strat.valid?(deploy)
  end

  it "is not valid if gitSha property is not present" do
    artifact = mock
    artifact.stubs(:properties).returns({})

    Artifactory::Resource::Artifact
      .stubs(:from_url)
      .with("https://artifactory.example/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
      .returns(artifact)

    deploy = Deploy.from_hash("artifact_url" => "https://artifactory.example/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
    refute @strat.valid?(deploy)
  end

  it "should use Artifactory to pull build" do
    local_artifact = File.join(@env.payload.artifacts_path, "WFS-153.jar")

    artifact = mock
    artifact.stubs(:download_uri).returns("https://artifactory.example/artifactory/pd-canoe/WFST/WFS/WFS-153.jar")
    Artifactory.client
      .expects(:get)
      .with("/artifactory/pd-canoe/WFST/WFS/WFS-153.jar")
      .returns("hello world!")

    Artifactory::Resource::Artifact
      .stubs(:from_url)
      .with("https://artifactory.example/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
      .returns(artifact)

    deploy = Deploy.from_hash("artifact_url" => "https://artifactory.example/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
    assert_equal local_artifact, @strat.fetch(deploy)
  end

  it "should be type artifactory" do
    assert_equal :artifactory, @strat.type
  end

end
