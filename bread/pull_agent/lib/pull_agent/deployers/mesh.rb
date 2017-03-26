module PullAgent
  module Deployers
    class Mesh
      DeployerRegistry["mesh"] = self

      def initialize(environment, deploy)
        @environment = environment
        @deploy = deploy
      end

      def deploy
        current_deploy = BuildVersion.load_from_directory(release_directory.current_symlink)
        if current_deploy && current_deploy.instance_of_deploy?(@deploy)
          Logger.log(:info, "Requested deploy is already present in #{release_directory.current_symlink}. Skipping fetch step.")
        else
          quick_rollback = QuickRollback.new(release_directory, @deploy)
          unless quick_rollback.perform
            Dir.mktmpdir do |temp_dir|
              ArtifactFetcher.new(@deploy.artifact_url).fetch_into(temp_dir)
              DirectorySynchronizer.new(temp_dir, release_directory.standby_directory).synchronize

              @deploy.to_build_version.save_to_directory(release_directory.standby_directory)
              release_directory.make_standby_directory_live
            end
          end
        end

        AtomicSymlink.create!(
          File.join(release_directory, "shared", ".envvars_#{@environment}"),
          File.join(release_directory.current_symlink, ".envvars_#{@environment}"),
        )

        AtomicSymlink.create!(
          File.join(release_directory, "shared", "database.yml"),
          File.join(release_directory.current_symlink, "config", "database.yml"),
        )

        AtomicSymlink.create!(
          File.join(release_directory, "log"),
          File.join(release_directory.current_symlink, "log"),
        )

        PumaService.new("/var/run/mesh/puma.pid").restart
      end

      def restart
      end

      private

      def release_directory
        @release_directory ||=
          ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/mesh"))
      end
    end
  end
end
