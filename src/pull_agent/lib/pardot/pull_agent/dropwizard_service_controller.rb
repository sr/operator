module Pardot
  module PullAgent
    class DropwizardServiceController
      RestartUnsuccessfulError = Class.new(StandardError)

      # How long to wait before restarting the service to give the load balancer
      # time to notice the node is down
      DEFAULT_PLAY_DEAD_WAIT_TIME = 30

      # How long to wait for the service to start back up until we give up
      DEFAULT_RESTART_WAIT_TIME = 180

      attr_accessor :restart_wait_time, :play_dead_wait_time

      def initialize(underlying_service, play_dead_controller: nil)
        @underlying_service = underlying_service
        @play_dead_controller = play_dead_controller

        @restart_wait_time = DEFAULT_RESTART_WAIT_TIME
        @play_dead_wait_time = DEFAULT_PLAY_DEAD_WAIT_TIME
      end

      def restart
        if @play_dead_controller
          Logger.log(:info, "Requesting that service play dead")
          @play_dead_controller.make_play_dead
          sleep @play_dead_wait_time
        end

        @underlying_service.restart

        if @play_dead_controller
          wait_max_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) + @restart_wait_time
          catch :restart_successful do
            until Process.clock_gettime(Process::CLOCK_MONOTONIC) > wait_max_time
              begin
                Logger.log(:info, "Attempting to make service live again via play dead controller")

                @play_dead_controller.make_alive
                throw :restart_successful
              rescue => e
                Logger.log(:info, "Service is not available yet, retrying: #{e}")
                sleep 0.5
              end
            end

            raise RestartUnsuccessfulError, "Service did not start within #{@restart_wait_time} seconds"
          end
        end
      end
    end
  end
end
