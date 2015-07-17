# Wrapper for Amazon S3 Authentication Tool for Curl - http://aws.amazon.com/code/128
require 'shell_helper'

class S3Curl
  def initialize(environment)
    @environment = environment
  end

  def getHeader(file)
    ShellHelper.execute_shell("#{@environment.scripts_path}/vendor/s3-curl/s3curl.pl --id=bamboo --head --  --silent #{file}")
  end

  def getFile(file, local_dir = File.join(@environment.scripts_path, "artifacts"))
    # Puts file in the artifacts directory
    ShellHelper.execute_shell("cd #{local_dir}" + \
      "&& #{@environment.scripts_path}/vendor/s3-curl/s3curl.pl --id=bamboo --  -O #{file}#{@environment.conductor.silent? ? " --silent" : ""}")
    # TODO: should we check and report $?.exitstatus
  end
end
