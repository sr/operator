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

  def valid?(deploy)
    return false unless deploy.artifact_url
    artifact = Artifact.from_url(deploy.artifact_url)
    artifact && artifact.properties["gitSha"]
  rescue Artifactory::Error::HTTPError
    false
  end

  def fetch(deploy)
    # returns path to fetched asset (file or directory)
    artifact = Artifact.from_url(deploy.artifact_url)
    artifact.download(environment.payload.local_artifacts_path)
  end
end
