module PullAgent
  module Deployers
    class Repfix
      DeployerRegistry["repfix"] = self

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

        AtomicSymlink.create!(
          File.join(release_directory, "shared", "env.rb"),
          File.join(release_directory.current_symlink, "env.rb"),
        )

        AtomicSymlink.create!(
          File.join(release_directory, "shared", ".envvars_#{@environment}.rb"),
          File.join(release_directory.current_symlink, ".envvars_#{@environment}.rb"),
        )

        AtomicSymlink.create!(
          File.join(release_directory, "log"),
          File.join(release_directory.current_symlink, "log"),
        )

        AtomicSymlink.create!(
          File.join(release_directory, "output"),
          File.join(release_directory.current_symlink, "output"),
        )

        PumaService.new("/var/run/repfix/puma.pid").restart
      end

      def restart
      end

      private

      def release_directory
        @release_directory ||=
          ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/repfix"))
      end
    end
  end
end
