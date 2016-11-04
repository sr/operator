module Pardot
  module PullAgent
    class QuickRollback
      def initialize(release_directory, deploy)
        @release_directory = release_directory
        @deploy = deploy
      end

      # Is this deploy suitable for a quick rollback?
      def applicable?
        standby_version = BuildVersion.load_from_directory(@release_directory.standby_directory)
        standby_version && standby_version.instance_of_deploy?(@deploy)
      end

      def perform_if_applicable
        return false unless applicable?

        @release_directory.make_standby_directory_live
        true
      end
    end
  end
end
