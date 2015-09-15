require "fetch_strategy_base"
require 'artifactory'
require 'base64'

class FetchStrategyArtifactory < FetchStrategyBase
  include Artifactory::Resource
  attr_accessor :environment

  def initialize(environment)
    self.environment = environment

    Artifactory.configure do |config|
      config.endpoint = 'https://artifactory.dev.pardot.com/artifactory'
      config.username = 'sa_bamboo'
      config.password = Base64.decode64('QVA2SzR2Rk43RUVCUjVmNUNINlkxbTNEQ2Y3SlNhY2JTNHZQMndTYmhyYXMxczFFQg==')
      config.ssl_verify = true
    end
  end

  def valid?(value)
    artifact_url = environment.deploy_options[:artifact_url]
    return false unless artifact_url
    artifact = Artifact.from_url(artifact_url)
    artifact && artifact.properties["gitSha"]
  rescue Artifactory::Error::HTTPError
    false
  end

  def fetch(value)
    # returns path to fetched asset (file or directory)
    artifact = Artifact.from_url(environment.deploy_options[:artifact_url])
    artifact.download(environment.payload.local_artifacts_path)
  end

  def get_tag_and_hash(value)
    artifact = Artifact.from_url(environment.deploy_options[:artifact_url])
    [value, artifact.properties["gitSha"].first]
  end
end
