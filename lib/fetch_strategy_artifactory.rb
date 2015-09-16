require "fetch_strategy_base"
require 'artifactory'

class FetchStrategyArtifactory < FetchStrategyBase
  include Artifactory::Resource
  attr_accessor :environment

  def initialize(environment)
    self.environment = environment

    Artifactory.configure do |config|
      config.endpoint = 'https://artifactory.dev.pardot.com/artifactory'
      config.username = environment.artifactory_user
      config.password = environment.artifactory_token
      config.ssl_verify = true
      if environment.artifactory_proxy
        p_address, p_port = environment.artifactory_proxy.split(':')
        config.proxy_address = p_address
        config.proxy_port = p_port
      end
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
