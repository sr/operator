module PullAgent
  module Deployers
    class EngagementHistoryTopology < TopologyDeploy
      DeployerRegistry["engagement-history-topology"] = self

      protected

      def release_directory
        @release_directory ||=
          ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/engagement-history-topology"))
      end
    end
  end
end
