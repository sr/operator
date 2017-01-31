module PullAgent
  module Deployers
    class Murdoc
      DeployerRegistry["murdoc"] = self

      def initialize(environment, deploy)
        @environment = environment
        @deploy = deploy
      end

      def deploy
        TopologyDeploy.new(@deploy, release_directory)
      end

      def restart
      end

      private

      def release_directory
        @release_directory ||=
          ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/murdoc"))
      end
    end
  end
end
