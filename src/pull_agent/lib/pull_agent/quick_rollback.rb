module PullAgent
  class QuickRollback
    def initialize(release_directory, deploy)
      @release_directory = release_directory
      @deploy = deploy
    end

    def perform
      if applicable?
        @release_directory.make_standby_directory_live
        true
      else
        false
      end
    end

    private

    # Is this deploy suitable for a quick rollback?
    def applicable?
      standby_version = BuildVersion.load_from_directory(@release_directory.standby_directory)
      standby_version && standby_version.instance_of_deploy?(@deploy)
    end
  end
end
