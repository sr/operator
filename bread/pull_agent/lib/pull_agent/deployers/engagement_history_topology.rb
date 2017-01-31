module PullAgent
  module Deployers
    class EngagementHistoryTopology
      DeployerRegistry["engagement-history-topology"] = self

      def initialize(environment, deploy)
        @environment = environment
        @deploy = deploy
      end

      def deploy
        TopologyDeploy.new(@deploy, release_directory).deploy
      end

      def restart
      end

      private

      def release_directory
        @release_directory ||=
          ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/engagement-history-topology"))
      end
    end
  end
end
