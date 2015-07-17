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
  def valid?(label)
    artifact_metadata = s3curl.getHeader(remote_artifact_file(label))
    !!artifact_metadata[/HTTP.*200.*/]
  end

  # returns path to dir where payload was fetched
  def fetch(label)

    local_artifacts_path = environment.payload.local_artifacts_path
    FileUtils.mkpath(local_artifacts_path) unless File.directory?(local_artifacts_path)
    local_file = File.join(local_artifacts_path, "#{environment.payload.artifact_prefix}#{label}.tar.gz")

    if File.exist?(local_file)
      Console.log("Artifact is already downloaded. Continuing...", :green)
    else
      Console.log("Pulling #{label} from S3....", :green)
      s3curl.getFile(remote_artifact_file(label), local_artifacts_path)
    end

    # tarball strategy returns the path to the tarball
    local_file
  end
end
