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

  def valid?(type, value)
    artifact = Artifact.search(name: name_for(type, value)).first
    !artifact.nil?
  end

  def fetch(type, value)
    # returns path to fetched asset (file or directory)
    artifact = Artifact.search(name: name_for(type, value)).first
    unless artifact.nil?
      # Check if the file exists locally first, and skip download?
      artifact.download(environment.payload.local_artifacts_path)
    else
      ""
    end
  end

  def get_tag_and_hash(type, value)
    #case type
    #when :tag
      artifact = Artifact.search(name: name_for(type, value)).first
      hash = /(?<hash>\w+).jar/.match(artifact.uri)[:hash]
      [value, hash]
    #when :commit
    #  artifacts = Artifact.search(name: name_for(type,value))

  end

  private

  def name_for(type, value)
    #case type
    #when :tag
      buildnumber = /build(?<num>\d+)/.match(value)[:num]
      "#{environment.payload.artifact_prefix}-#{buildnumber}-"
    #when :commit
    #  value
    #when :artifact
    #  value
    #end
  end
end
