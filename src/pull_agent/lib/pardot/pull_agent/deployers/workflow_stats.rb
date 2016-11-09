module Pardot
  module PullAgent
    module Deployers
      class WorkflowStats
        DeployerRegistry["workflow-stats"] = self

        # How long to wait before restarting the service to give the load balancer
        # time to notice the node is down
        PLAY_DEAD_WAIT_TIME = 30

        # How long to wait for the service to start back up until we give up
        RESTART_WAIT_TIME = 180

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
          unless quick_rollback.perform
            Dir.mktmpdir do |temp_dir|
              ArtifactFetcher.new(@deploy.artifact_url).fetch_into(temp_dir)
              DirectorySynchronizer.new(temp_dir, release_directory.standby_directory).synchronize

              @deploy.to_build_version.save_to_directory(release_directory.standby_directory)
              release_directory.make_standby_directory_live
            end
          end

          play_dead_controller = PlayDeadController.new
          play_dead_controller.make_play_dead
          sleep(PLAY_DEAD_WAIT_TIME)

          UpstartService.new("workflowstats").restart

          wait_max_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) + RESTART_WAIT_TIME
          catch :restart_successful do
            until Process.clock_gettime(Process::CLOCK_MONOTONIC) > wait_max_time
              begin
                Logger.log(:info, "Attempting to make service live again via play dead controller")

                play_dead_controller.make_alive
                throw :restart_successful
              rescue => e
                Logger.log(:info, "Service is not available yet, retrying: #{e}")
                sleep 0.5
              end
            end

            raise DeploymentError, "Service did not start within #{@restart_wait_time} seconds"
          end
        end

        def perform_restart
        end

        def release_directory
          @release_directory ||=
            ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/workflow_stats"))
        end
      end
    end
  end
end
