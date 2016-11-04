module Pardot
  module PullAgent
    module Deployers
      class Pardot
        DeployerRegistry["pardot"] = self

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
        end

        private

        def perform_deploy
          release_directory = ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/var/www/pardot"))

          quick_rollback = QuickRollback.new(release_directory, @deploy)
          if quick_rollback.perform_if_applicable
            # Quick rollback performed. Nothing else to do
          else
            Dir.mktmpdir do |temp_dir|
              fetcher = ArtifactFetcher.new(@deploy.artifact_url)
              fetcher.fetch_into(temp_dir)

              DirectorySynchronizer.new(temp_dir, release_directory.standby_directory).synchronize

              @deploy.to_build_version.save_to_directory(release_directory.standby_directory)
              release_directory.make_standby_directory_live
            end
          end

          Canoe.notify_server(@environment, @deploy)
        end

        def perform_restart
        end
      end
    end
  end
end
