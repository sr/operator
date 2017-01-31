module PullAgent
  module Deployers
    class Murdoc < TopologyDeploy
      DeployerRegistry["murdoc"] = self

      protected

      def release_directory
        @release_directory ||=
          ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/murdoc"))
      end
    end
  end
end
