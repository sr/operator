module PullAgent
  module Deployers
    class Pithumbs
      DeployerRegistry["pithumbs"] = self

      def initialize(environment, deploy)
        @environment = environment
        @deploy = deploy
      end

      def deploy
        quick_rollback = QuickRollback.new(release_directory, @deploy)
        unless quick_rollback.perform
          Dir.mktmpdir do |temp_dir|
            ArtifactFetcher.new(@deploy.artifact_url).fetch_into(temp_dir)
            DirectorySynchronizer.new(temp_dir, release_directory.standby_directory).synchronize

            @deploy.to_build_version.save_to_directory(release_directory.standby_directory)
            release_directory.make_standby_directory_live
          end
        end

        UpstartService.new("pithumbs").restart
      end

      def restart
      end

      private

      def release_directory
        @release_directory ||=
          ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/var/www/pithumbs"))
      end
    end
  end
end
