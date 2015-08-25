require_relative "test_helper.rb"
require "fetch_strategy_artifactory"

describe FetchStrategyArtifactory do
  before do
    @env = EnvironmentTest.new
    @env.payload = :'workflow-stats'
    @strat = FetchStrategyArtifactory.new(@env)
  end

  it "should use Artifactory to check validity of tag" do
    Artifactory::Resource::Artifact.expects(:search).with(name: "workflowstats-1.0SNAPSHOT-1234-").returns(["foo"])
    assert @strat.valid?(:tag, "build1234")
  end

  it "should use Artifactory to pull tag" do
    tag_value = "build1234"
    local_artifact = @env.payload.local_artifacts_path + '/' + tag_value
    artifact = mock
    artifact.expects(:download).with(@env.payload.local_artifacts_path).returns(local_artifact)
    Artifactory::Resource::Artifact.expects(:search).with(name: "workflowstats-1.0SNAPSHOT-1234-").returns([artifact])
    assert_equal local_artifact, @strat.fetch(:tag, tag_value)
  end

  it "should be type git" do
    assert_equal :artifactory, @strat.type
  end

end
