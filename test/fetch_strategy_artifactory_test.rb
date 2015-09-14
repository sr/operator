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
      .with("https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
      .returns(artifact)

    @env.deploy_options[:artifact_url] = "https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar"
    assert @strat.valid?("build123")
  end

  it "is not valid if gitSha property is not present" do
    artifact = mock
    artifact.stubs(:properties).returns({})

    Artifactory::Resource::Artifact
      .stubs(:from_url)
      .with("https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
      .returns(artifact)

    @env.deploy_options[:artifact_url] = "https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar"
    refute @strat.valid?("build123")
  end

  it "should use Artifactory to pull build" do
    local_artifact = @env.payload.local_artifacts_path + '/' + "wfs"

    artifact = mock
    artifact.expects(:download).with(@env.payload.local_artifacts_path).returns(local_artifact)

    Artifactory::Resource::Artifact
      .stubs(:from_url)
      .with("https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar")
      .returns(artifact)

    @env.deploy_options[:artifact_url] = "https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.jar"
    assert_equal local_artifact, @strat.fetch("build123")
  end

  it "should be type artifactory" do
    assert_equal :artifactory, @strat.type
  end

end
