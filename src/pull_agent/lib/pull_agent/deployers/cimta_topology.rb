module PullAgent
  module Deployers
    class CimtaTopology < TopologyDeploy
      DeployerRegistry["cimta-topology"] = self

      protected

      def release_directory
        @release_directory ||=
          ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/cimta-topology"))
      end
    end
  end
end

