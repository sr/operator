module Pardot
  module PullAgent
    class UpstartServiceController
      def initialize(service_name, shell_executor: ShellExecutor.new)
        @service_name = service_name
        @shell_executor = shell_executor
      end

      def restart
        result = @shell_executor.execute(["sudo", "/sbin/restart", @service_name], err: [:child, :out])
        if result.include?("#{@service_name} start/running")
          Logger.log(:info, "Restarted #{@service_name} service")
        elsif result.include?("Unknown instance")
          Logger.log(:info, "#{@service_name} service was not running, attempting start")

          start_result = @shell_executor.execute(["sudo", "/sbin/start", @service_name], err: [:child, :out])
          if start_result.include?("#{@service_name} start/running")
            Logger.log(:info, "Started #{@service_name} service")
          else
            Logger.log(:err, "Unable to start #{@service_name} service: #{start_result}")
          end
        else
          Logger.log(:err, "Unable to restart #{@service_name} service: #{result}")
        end
      end
    end
  end
end
