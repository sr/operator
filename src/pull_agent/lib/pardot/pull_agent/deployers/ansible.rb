module Pardot
  module PullAgent
    module Deployers
      class Ansible
        DeployerRegistry["ansible"] = self

        def initialize(environment, deploy)
          @environment = environment
          @deploy = deploy
        end

        def perform
          case @deploy.action
          when "deploy"
            perform_deploy
          when "restart"
            perform_restart
          else
            raise DeploymentError, "unknown action: #{@deploy.action}"
          end

          Canoe.notify_server(@environment, @deploy)
        end

        private

        def perform_deploy
          quick_rollback = QuickRollback.new(release_directory, @deploy)
          unless quick_rollback.perform_if_applicable
            Dir.mktmpdir do |temp_dir|
              ArtifactFetcher.new(@deploy.artifact_url).fetch_into(temp_dir)
              DirectorySynchronizer.new(temp_dir, release_directory.standby_directory).synchronize

              @deploy.to_build_version.save_to_directory(release_directory.standby_directory)
              release_directory.make_standby_directory_live
            end
          end

          AtomicSymlink.create!(
            File.join(release_directory.current_symlink, "production_#{ShellHelper.datacenter}.ini"),
            File.join(release_directory.current_symlink, "hosts"),
          )
        end

        def perform_restart
        end

        def release_directory
          @release_directory ||=
            ReleaseDirectory.new(
              ENV.fetch("RELEASE_DIRECTORY", "/etc/ansible-releases"),
              current_directory: "../ansible",
            )
        end
      end
    end
  end
end
