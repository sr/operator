require "fetch_strategy_base"
require "s3curl"
require "shell_helper"
require "fileutils"

class FetchStrategyTarball < FetchStrategyBase

  def s3curl
    @_s3curl ||= S3Curl.new(environment)
  end

  def remote_artifact_file(tag)
    "http://s3.amazonaws.com/#{environment.payload.s3_bucket}.deploy.pardot.com/#{environment.payload.artifact_prefix}#{tag}.tar.gz"
  end

  # returns boolean indicating the requested build is available
  def valid?(deploy)
    return false unless deploy.what == "tag"

    artifact_metadata = s3curl.getHeader(remote_artifact_file(deploy.what_details))
    !!artifact_metadata[/HTTP.*200.*/]
  end

  # returns path to dir where payload was fetched
  def fetch(deploy)
    artifacts_path = environment.payload.artifacts_path
    FileUtils.mkpath(artifacts_path) unless File.directory?(artifacts_path)
    local_file = File.join(artifacts_path, "#{environment.payload.artifact_prefix}#{deploy.what_details}.tar.gz")

    if File.exist?(local_file)
      Console.log("Artifact is already downloaded. Continuing...", :green)
    else
      Console.log("Pulling #{deploy.what_details} from S3....", :green)
      s3curl.getFile(remote_artifact_file(deploy.what_details), artifacts_path)
    end

    # tarball strategy returns the path to the tarball
    local_file
  end
end
